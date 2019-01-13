#
## @file interp_dox.tcl
#  @brief Liste des fichiers et des procédures commentées de l'interpréteur de base (sans namespace spécifique)
#  @author Raymond Zachantke
#  $Id: interp_dox.tcl 13906 2016-05-25 12:33:44Z rzachantke $
#

## namespace aanonyme
#  @brief Liste des fichiers et des procédures commentées de l'interpréteur de base (sans namespace spécifique)
#  <table>
#  <caption>Liste des des fichiers et des procs de l'interpréteur de base (sans namespace)</caption>
#  <tr><th> Fichier </th><th> Fonctions </th></tr>
#  <tr><td> alpy600_tools.tcl </td><td></td></tr>
#  <tr><td> aud_proc.tcl </td><td>
#  @ref add @ref animate @ref audace_ping @ref binx @ref biny @ref clipmax @ref clipmin @ref delete2
#  @ref dir @ref fitsdate @ref loadima @ref mirrorx @ref mirrory @ref mult @ref noffset @ref offset
#  @ref rot @ref stat @ref sub @ref window
#  </td></tr>
#  <tr><td> audnet.tcl </td><td></td></tr>
#  <tr><td> bifsconv.tcl </td><td>
#  @ref bifsconv @ref convert_fits @ref convert_fits_all
#  @ref convert_fits_subdir @ref bifsconv_full @ref loadima_nofits
#  </td></tr>
#  <tr><td> catalog_tools.tcl </td><td>
#  @ref catalog2buf @ref pole2buf
#  </td></tr>
#  <tr><td> celestial_mechanics.tcl </td><td>
#  @ref coord2offset @ref coordofzenith @ref meteores_zhr @ref name2coord
#  </td></tr>
#  <tr><td> compute_stellaire.tcl </td><td>
#  @ref compute_stellaire
#  </td></tr>
#  <tr><td> diaghr.tcl </td><td>
#  @ref diaghr_extract  @ref diaghr_plot
#  </td></tr>
#  <tr><td> divers.tcl </td><td>
#  @ref aligne @ref calcul_trzaligne @ref charge @ref compare_index_series @ref copie @ref copie_partielle
#  @ref cree_fichier @ref cree_sousrep @ref date_chiffresAlettres @ref decomp @ref dernier_est_chiffre
#  @ref isRaw @ref liste_index @ref liste_series @ref liste_sousreps @ref lmax @ref lmax @ref mediane
#  @ref nom_valide @ref normalise @ref normalise_gain @ref numerotation_usuelle @ref range_options
#  @ref raw2fits @ref renomme @ref renumerote @ref sauve @ref sauve_jpeg @ref serie_charge @ref serie_existe
#  @ref serie_fenetre @ref serie_normalise @ref serie_rot @ref serie_sauvejpeg @ref serie_soustrait
#  @ref serie_trans @ref series_traligne @ref souris_fenetre @ref soustrait @ref suppr_accents @ref suppr_debut_serie
#  @ref suppr_fin_serie @ref suppr_serie @ref syntaxe_args @ref TestEntier @ref TestReel
#  </td></tr>
#  <tr><td> etc_tools.tcl </td><td>
#  @ref etc_disp @ref etc_inputs_set @ref etc_set_array_cameras
#  @ref etc_snr2m_computations @ref etc_snr2t_computations @ref etc_t2snr_computations
#  </td></tr>
#  <tr><td> filtrage.tcl </td><td>
#  @ref bm_filter @ref bm_filtre_max @ref bm_filtre_median @ref bm_filtre_min
#  @ref bm_passe_bas @ref bm_passe_haut @ref contraint_noyau @ref gradient_nose
#  </td></tr>
#  <tr><td> focas.tcl </td><td>
#  @ref focas_catastars2pairs
#  </td></tr>
#  <tr><td> ftp.tcl </td><td>
#  @ref ftpgetopen @ref ftpglob @ref ftpscriptopen
#  </td></tr>
#  <tr><td> gcn_tools.tcl </td><td></td></tr>
#  <tr><td> grb_tools.tcl </td><td>
#  @ref grb_antares @ref grb_gcnc @ref grb_greiner @ref grb_swift
#  </td></tr>
#  <tr><td> ftp.tcl </td><td>
#  @ref ftpgetopen @ref ftpglob @ref ftpscriptopen
#  </td></tr>
#  <tr><td> iris.tcl </td><td>
#  @ref iris @ref iris2_compute_trichro1 @ref iris2_select
#  </td></tr>
#  <tr><td> joystick_tools.tcl </td><td>
#  @ref joystick_close @ref joystick_get @ref joystick_getall @ref joystick_open @ref joystick_resource_read
#  @ref joystick_resource_state @ref joystick_resource_update @ref testxBoxOne
#  </td></tr>
#  <tr><td> mauclaire.tcl </td><td>
#  @ref bm_addmotcleftxt @ref bm_autoflat @ref bm_autoflat2 @ref bm_cleanfit @ref bm_cp @ref bm_correctprism
#  @ref bm_cutima @ref bm_datefile @ref bm_datefrac @ref bm_exptime @ref bm_extract_radec @ref bm_extractkwd
#  @ref bm_fwhm @ref bm_goodrep @ref bm_hotchart @ref bm_ls @ref bm_maximext @ref bm_mkdir @ref bm_mv
#  @ref bm_ovakwd @ref bm_plot @ref bm_pretrait @ref bm_pretraittot @ref bm_register @ref bm_registerhplin
#  @ref bm_registerplin @ref bm_renameext @ref bm_renameext2 @ref bm_renumfile @ref bm_rm @ref bm_sadd
#  @ref bm_sflat @ref bm_smean @ref bm_smed @ref bm_somes @ref bm_sphot @ref bm_zoomima
#  </td></tr>
#  <tr><td> menu.tcl </td><td>
#  @ref Menu_Check @ref Menu_Command @ref Menu_Command_Radiobutton @ref Menu_Delete
#  </td></tr>
#  <tr><td> meteosensor_tools.tcl </td><td>
#  @ref readCumulus @ref readSentinelFile
#  </td></tr>
#  <tr><td> miscellaneous.tcl </td><td>
#  @ref airmass @ref airmass2 @ref list2file
#  </td></tr>
#  <tr><td> photcal.tcl </td><td></td></tr>
#  <tr><td> photompsf.tcl </td><td></td></tr>
#  <tr><td> photrel.tcl </td><td>
#  @ref photrel_cal2cat @ref photrel_cat2con @ref photrel_cat2mes @ref photrel_cat2per @ref photrel_cat2var @ref photrel_demo
#  @ref photrel_elem2ephem @ref photrel_mes2mes @ref photrel_nom2cal @ref photrel_wcs2cat @ref photrel_wcs2var
#  </td></tr>
#  <tr><td> planetography.tcl </td><td>
#  @ref lonlat2radec @ref radec2lonlat
#  </td></tr>
#  <tr><td> pneb_tools.tcl </td><td>
#  @ref pneb_int2tene
#  </td></tr>
#  <tr><td> poly.tcl </td><td>
#  @ref poly_fenetre @ref poly_nbcouleurs @ref polyAserie @ref polyAseries
#  @ref seriesApoly @ref poly_series_traligne @ref poly_rot @ref poly_souris_fenetre @ref poly_trans
#  </td></tr>
#  <tr><td> satel.tcl </td><td>
#  @ref satel_coords @ref satel_ephem @ref satel_names @ref satel_nearest_radec
#  @ref satel_scene @ref satel_transit @ref satel_update @ref satel_zone_radec
#  </td></tr>
#  <tr><td> sextractor.tcl </td><td></td></tr>
#  <tr><td> socket_tools.tcl </td><td>
#  @ref socket_server_accept @ref socket_client_close @ref socket_client_get @ref socket_client_open @ref socket_client_put
#  @ref socket_server_close @ref socket_server_open @ref socket_server_respons @ref socket_server_respons_debug
#  </td></tr>
#  <tr><td> speckle_tools.tcl </td><td>
#  @ref speckle_avi2intercor @ref speckle_intercorfft @ref speckle_intercorhighpass @ref speckle_avi2fits
#  </td></tr>
#  <tr><td rowspan="6"> surchaud.tcl </td>
#  <tr><td>Traitement d'une image dans le buffer : @ref convgauss @ref hotpixels @ref mult @ref offset @ref trans </td></tr>
#  <tr><td>Traitement d'une série d'images : @ref delete2 </td></tr>
#  <tr><td>Traitement d'une pile d'images : @ref sadd @ref sdrizzlewcs @ref smean @ref smedian @ref sprod @ref spythagore @ref ssigma @ref ssk @ref ssort </td></tr>
#  <tr><td>Calibration d'images : @ref calibwcs @ref calibwcs_new @ref calibwcs2 </td></tr>
#  <tr><td>Synthèse d'images : @ref electronic_chip @ref simulimage @ref simulimage2 </td></tr>
#  </tr>
#  <tr><td> vo_tools.tcl </td><td>@ref vo_aladin @ref vo_entityEncode @ref vo_launch_aladin
#  @ref vo_miriade_ephemcc @ref vo_miriadeXML @ref vo_name2coord @ref vo_neareststar @ref vo_sesame @ref vo_sesame_url
#  @ref vo_skybotconesearch @ref vo_skybotresolver @ref vo_skybotstatus @ref vo_skybotXML @ref vo_vizier_query</td>
#  </tr>
#  <tr><td> wcs_tools.tcl </td><td>
#  @ref wcs_apparent_parameters @ref wcs_buf2wcs @ref wcs_builder @ref wcs_cd2cdelt @ref wcs_cdelt2cd @ref wcs_dispkwd
#  @ref wcs_focaspairs2wcs@ref wcs_getkwd @ref wcs_optic2wcs @ref wcs_p2radec @ref wcs_plot_catalog @ref wcs_radec2p @ref wcs_radec2xy
#  @ref wcs_radec_app2cat @ref wcs_radec_cat2app @ref wcs_setkwd @ref wcs_update_optic @ref wcs_xy2radec @ref wcs_wcs2buf
#  </td></tr>
#  <tr><td> world_tools.tcl </td><td>
#  @ref world_jpegmap @ref world_plotmap @ref world_shiftmap
#  </td></tr>
#  </table>
#

namespace eval ::aanonyme { }

