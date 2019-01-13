## @file eye.funcs.demo.tcl
#  @brief     Projet EYE : Pilotage d un chercheur electronique asservissant une monture
#  @author    Frederic Vachier
#  @date      2013
#  @copyright GNU Public License.
#  @warning  Outil en developpement
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool eye eye.tcl]
#  @endcode
#  @version \$Id: eye.funcs.demo.tcl 14055 2016-10-01 00:20:40Z fredvachier $

# Demo de la recherche du pole mecanique
# video montrant le mouvement de rotation sur l axe Alpha
   proc ::eye::demo_load_meca {  }  {
      ::eye::demo_load_meca_3
   }

   proc ::eye::demo_load_meca_1 {  }  {

      # Camera
      set ::atos_tools::traitement "avi"
      set ::atos_tools::avi_filename "/data/Chercheur_Electro/2015-04-08_Rotoir/polaris_slow4_25mm_rotation-20150408T203412-000.avi"
      ::atos_tools_avi::open_flux $::eye::visuNo
      ::atos_tools::set_frame $::eye::visuNo 550
      ::atos_tools_avi::next_image
      ::audace::autovisu $::eye::visuNo

      # simu
      set ::eye::widget(coord,wanted,raJ2000)  "02h31m49.1s" 
      set ::eye::widget(coord,wanted,decJ2000) "+89d15m51s"
      set ::eye::widget(fov,nbstars) 52
      set ::eye::widget(fov,orient) 262
      set ::eye::widget(fov,xflip) 0
      set ::eye::widget(fov,yflip) 0

      catch {::eye::fov_close}
      ::eye::fov_view

      ::eye::fov_tools_clear

      # array get ::eye::stars
      set l [list \
                 5,simu,nbmes 1 2,cam,nbmes 1 4,cam,snint 2.6 1,cam,err_sky 1.5 \
                 7,cam,rdiff 4.0 3,cam,err_sky 0.4 3,cam,pixmax 74.0 \
                 1,simu,dec 89.263453 7,simu,sky 402.01478465851397 6,cam,nbmes 1 \
                 2,simu,mag {} 5,cam,err_sky 0.3 5,cam,crpix1 419.9 5,cam,crpix2 431.9 \
                 4,simu,snint 0 7,cam,err_sky 0.7 6,simu,rdiff 1.4945488767320472 \
                 2,simu,pixmax 0 4,simu,pixmax 0 1,simu,rdiff 2.2681780341996904 \
                 6,simu,err_sky 0 6,simu,pixmax 0 3,cam,intensity 39.4 \
                 7,simu,intensity 302.94575072380263 2,simu,dec 86.258673 3,simu,mag {} \
                 6,cam,pixmax 54.0 3,simu,nbmes 1 1,simu,sky 403.18675673400185 \
                 1,cam,snint 27.7 7,cam,intensity 20.9 4,cam,rdiff 3.6 3,simu,err_sky 0 \
                 7,simu,snint 0 3,cam,nbmes 1 1,cam,pixmax 254.0 5,cam,snint 2.1 \
                 6,simu,intensity 238.83311455136587 3,cam,crpix1 545.6 3,cam,crpix2 136.9 \
                 2,simu,snint 0 7,cam,nbmes 1 4,simu,rdiff 1.782333135515638 \
                 3,simu,dec 86.587209 4,simu,mag {} 2,simu,crpix1 257.6 \
                 2,simu,sky 401.76201856068008 2,simu,crpix2 231.8 6,simu,nbmes 1 \
                 4,simu,crpix1 240.4 5,simu,intensity 145.69331489997347 \
                 4,simu,crpix2 60.1 1,simu,ra 37.905360 2,cam,intensity 66.0 \
                 6,simu,crpix1 334.4 2,simu,ra 17.214206 6,simu,crpix2 185.7 \
                 4,cam,pixmax 68.0 3,simu,ra 263.025688 1,simu,nbmes 1 \
                 4,simu,ra 343.603776 1,cam,rdiff 2.3 6,cam,intensity 19.0 \
                 6,cam,crpix1 340.8 5,simu,ra 115.090137 4,simu,dec 84.347550 \
                 6,simu,ra 351.751524 6,cam,crpix2 181.6 5,simu,snint 0 \
                 2,cam,snint 4.6 5,simu,mag {} 7,simu,ra 333.288150 \
                 7,simu,rdiff 1.4347612325735812 3,simu,sky 403.57374862391964 \
                 5,cam,rdiff 3.6 4,simu,intensity 260.87408252266812 \
                 1,cam,crpix1 403.9 5,simu,err_sky 0 4,cam,nbmes 1 1,cam,crpix2 279.0 \
                 2,cam,err_sky 0.4 6,cam,snint 1.9 2,simu,rdiff 0.89454873529394308 \
                 4,cam,err_sky 0.7 6,cam,err_sky 0.5 1,simu,pixmax 0 7,cam,pixmax 56.0 \
                 5,simu,dec 87.022588 4,simu,nbmes 1 2,simu,err_sky 0 3,simu,pixmax 0 \
                 3,simu,intensity 778.3275633443111 6,simu,mag {} \
                 4,simu,sky 402.07414821974487 1,cam,intensity 219.0 5,simu,pixmax 0 \
                 2,cam,pixmax 101.0 7,simu,pixmax 0 4,cam,crpix1 260.4 \
                 5,cam,intensity 33.4 4,cam,crpix2 49.7 3,simu,snint 0 \
                 5,simu,rdiff 1.1920424290175509 2,cam,rdiff 3.3 1,cam,nbmes 0 \
                 2,simu,intensity 394.82465339403302 6,simu,dec 87.308246 \
                 3,cam,snint 2.9 1,cam,sky 35.0 7,simu,mag {} 7,simu,nbmes 1 \
                 6,cam,rdiff 1.0 5,simu,sky 401.95465897956626 2,cam,sky 35.0 \
                 5,cam,nbmes 1 3,cam,sky 34.6 7,cam,snint 2.1 7,simu,err_sky 0 \
                 4,cam,sky 35.3 5,cam,sky 34.6 5,cam,pixmax 68.0 2,simu,nbmes 1 \
                 6,cam,sky 35.0 1,simu,intensity 294.52899840003636 1,simu,crpix1 406.9 \
                 7,cam,sky 35.1 7,cam,crpix1 343.6 1,simu,crpix2 276.8 7,cam,crpix2 96.1 \
                 6,simu,snint 0 3,simu,crpix1 544.8 7,simu,dec 86.109223 4,simu,err_sky 0 \
                 3,simu,crpix2 124.1 5,simu,crpix1 434.6 2,cam,crpix1 264.1 \
                 6,simu,sky 401.74292764330374 5,simu,crpix2 426.9 1,simu,snint 0 \
                 2,cam,crpix2 222.2 1,simu,mag {} 7,simu,crpix1 331.2 \
                 4,cam,intensity 32.7 3,simu,rdiff 1.3172856102216539 \
                 7,simu,crpix2 102.2 1,simu,err_sky 0 3,cam,rdiff 1.2 \
            ]

      set ::eye::list_star { 1 2 3 4  6 7 }
      set ::eye::list_star_ok { 1 2 3 4  6 7 }

      array set ::eye::stars $l

      set ::eye::stars(1,cam,nbmes) 0
      set ::eye::stars(2,cam,nbmes) 0
      set ::eye::stars(3,cam,nbmes) 0
      set ::eye::stars(4,cam,nbmes) 0
      set ::eye::stars(5,cam,nbmes) 0
      set ::eye::stars(6,cam,nbmes) 0
      set ::eye::stars(7,cam,nbmes) 0
      set ::eye::stars(8,cam,nbmes) 0

      ::eye::fov_wcs
      ::eye::fov_wcs_review 

      return 0
   }



# Demo de la recherche du pole mecanique
# video montrant le mouvement de translation avec les axes de la monture

   proc ::eye::demo_load_meca_2 {  }  {

      # Camera
      set ::atos_tools::traitement "avi"
      set ::atos_tools::avi_filename "/data/Chercheur_Electro/2015-04-08_Rotoir/polaris_slow4_25mm_rotation-20150408T203412-000.avi"
      ::atos_tools_avi::open_flux $::eye::visuNo
      ::atos_tools::set_frame $::eye::visuNo 550
      ::atos_tools_avi::next_image
      ::audace::autovisu $::eye::visuNo

      return 0
   }

   proc ::eye::demo_load_meca_3 {  }  {

      # Camera
      set ::atos_tools::traitement "avi"
      set ::atos_tools::avi_filename "/data/Chercheur_Electro/2016-09-24_Test_MES/rotation_pole-20160924T212245-000.avi"
      ::atos_tools_avi::open_flux $::eye::visuNo
      ::atos_tools::set_frame $::eye::visuNo 550
      ::atos_tools_avi::next_image
      ::audace::autovisu $::eye::visuNo


      # simu
      set ::eye::widget(coord,wanted,raJ2000)  "02h31m49.1s" 
      set ::eye::widget(coord,wanted,decJ2000) "+89d15m51s"
      set ::eye::widget(fov,nbstars) 65
      set ::eye::widget(fov,orient) 293
      set ::eye::widget(fov,xflip) 0
      set ::eye::widget(fov,yflip) 0

      catch {::eye::fov_close}
      ::eye::fov_view

      ::eye::fov_tools_clear

      # array get ::eye::stars
      set l [list \
                 5,simu,nbmes 1 2,cam,nbmes 1 4,cam,snint 35.8 1,cam,err_sky 10.9 \
                  3,cam,err_sky 7.3 3,cam,pixmax 254.0 1,simu,dec 86.587024 \
                  5,cam,err_sky 4.8 5,cam,crpix1 426.1 2,simu,mag 5.3 5,cam,crpix2 \
                  127.2 4,simu,snint 0 2,simu,pixmax 0 4,simu,pixmax 0 1,simu,rdiff \
                  0.38409511141383235 3,cam,intensity 200.8 2,simu,dec 86.108438 \
                  3,simu,mag 4.4 3,simu,nbmes 1 1,simu,sky 407.99772658977616 \
                  1,cam,snint 43.2 4,cam,rdiff 2.2 3,simu,err_sky 0 3,cam,nbmes \
                  1 1,cam,pixmax 254.0 5,cam,snint 26.0 3,cam,crpix1 538.3 \
                  3,cam,crpix2 206.1 2,simu,snint 0 4,simu,rdiff 1.6609909737385704 \
                  3,simu,dec 86.257353 4,simu,mag 5.2 2,simu,crpix1 527.3 2,simu,sky \
                  407.13424000686365 2,simu,crpix2 369.3 4,simu,crpix1 244.6 \
                  5,simu,intensity 193.86111497330796 4,simu,crpix2 192.7 \
                  1,simu,ra 262.999403 2,cam,intensity 165.8 2,simu,ra 333.359892 \
                  4,cam,pixmax 225.0 3,simu,ra 17.159990 1,simu,nbmes 1 4,simu,ra \
                  115.132227 1,cam,rdiff 1.7 5,simu,ra 62.519771 4,simu,dec 87.020323 \
                  5,simu,snint 0 2,cam,snint 29.8 5,simu,mag 5.9 3,simu,sky \
                  407.42219262544165 5,cam,rdiff 0.2 4,simu,intensity 176.89787237230021 \
                  1,cam,crpix1 387.7 5,simu,err_sky 0 4,cam,nbmes 1 1,cam,crpix2 475.5 \
                  2,cam,err_sky 12.2 2,simu,rdiff 2.3768749719516404 4,cam,err_sky \
                  18.2 1,simu,pixmax 0 5,simu,dec 86.628516 4,simu,nbmes 1 2,simu,err_sky \
                  0 3,simu,pixmax 0 3,simu,intensity 479.78530158107083 4,simu,sky \
                  407.10992642970865 1,cam,intensity 198.9 5,simu,pixmax 0 2,cam,pixmax \
                  226.0 4,cam,crpix1 294.9 5,cam,intensity 134.8 4,cam,crpix2 169.2 \
                  3,simu,snint 0 5,simu,rdiff 3.943270375280516 2,cam,rdiff 2.1 \
                  1,cam,nbmes 1 2,simu,intensity 432.85178286202813 3,cam,snint 19.9 \
                  1,cam,sky 55.0 5,simu,sky 407.0533904002225 2,cam,sky 60.2 5,cam,nbmes \
                  1 3,cam,sky 53.2 4,cam,sky 57.3 5,cam,sky 52.2 5,cam,pixmax 187.0 \
                  2,simu,nbmes 1 1,simu,intensity 926.98983329280941 1,simu,crpix1 \
                  351.2 1,simu,crpix2 496.7 3,simu,crpix1 501.9 4,simu,err_sky 0 \
                  3,simu,crpix2 221.6 5,simu,crpix1 381.6 2,cam,crpix1 558.2 5,simu,crpix2 \
                  146.7 1,simu,snint 0 2,cam,crpix2 354.1 4,cam,intensity 167.7 3,simu,rdiff \
                  1.5612041265049237 1,simu,mag 4.3 1,simu,err_sky 0 3,cam,rdiff 5.4 \
             ]

      set ::eye::list_star { 1 2 3 4 5 }
      set ::eye::list_star_ok { 1 2 3 4 5 }

      array set ::eye::stars $l

      set ::eye::stars(1,cam,nbmes) 0
      set ::eye::stars(2,cam,nbmes) 0
      set ::eye::stars(3,cam,nbmes) 0
      set ::eye::stars(4,cam,nbmes) 0
      set ::eye::stars(5,cam,nbmes) 0

      ::eye::fov_wcs
      ::eye::fov_wcs_review 

      return 0
   }





   proc ::eye::demo_load_polaris_1 {  }  {

      # Camera
      set ::atos_tools::traitement "avi"
      set ::atos_tools::avi_filename "/data/Chercheur_Electro/2016-01-15_SaintCaprais/polaris-20160115T012006-000.avi"
      ::atos_tools_avi::open_flux $::eye::visuNo
      ::atos_tools::set_frame $::eye::visuNo 1
      ::atos_tools_avi::next_image
      ::audace::autovisu $::eye::visuNo

      return 0
   }
