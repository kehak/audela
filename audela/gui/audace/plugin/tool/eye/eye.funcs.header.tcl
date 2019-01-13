#
# Projet EYE
# Description : Pilotage d un chercheur electronique asservissant une monture
# Auteur : Frederic Vachier
# Mise a jour $Id: eye.funcs.header.tcl 11731 2015-03-28 11:37:02Z robertdelmas $
#

   #------------------------------------------------------------
   ## Mise a jour des mot cles du header dans le widget
   # @return void
   #
   proc ::eye::maj_widget_motscles { } {

      set ::eye::widget(keys,new,ra)        [mc_angle2hms [lindex [buf$::eye::bufNo getkwd "CRVAL1"] 1] 360 zero 1 auto string]
      set ::eye::widget(keys,new,dec)       [mc_angle2dms [lindex [buf$::eye::bufNo getkwd "CRVAL2"] 1] 90 zero 1 + string]
      set ::eye::widget(keys,new,equinox)   [lindex [buf$::eye::bufNo getkwd "EQUINOX"] 1]
      set ::eye::widget(keys,new,pixsize1)  [lindex [buf$::eye::bufNo getkwd "PIXSIZE1"] 1]
      set ::eye::widget(keys,new,pixsize2)  [lindex [buf$::eye::bufNo getkwd "PIXSIZE2"] 1]
      set ::eye::widget(keys,new,crpix1)    [lindex [buf$::eye::bufNo getkwd "CRPIX1"] 1]
      set ::eye::widget(keys,new,crpix2)    [lindex [buf$::eye::bufNo getkwd "CRPIX2"] 1]
      set ::eye::widget(keys,new,crval1)    [lindex [buf$::eye::bufNo getkwd "CRVAL1"] 1]
      set ::eye::widget(keys,new,crval2)    [lindex [buf$::eye::bufNo getkwd "CRVAL2"] 1]
      set ::eye::widget(keys,new,foclen)    [lindex [buf$::eye::bufNo getkwd "FOCLEN"] 1]
      set ::eye::widget(keys,new,crota2)    [lindex [buf$::eye::bufNo getkwd "CROTA2"] 1]
      set ::eye::widget(keys,new,cdelt1)    [lindex [buf$::eye::bufNo getkwd "CDELT1"] 1]
      set ::eye::widget(keys,new,cdelt2)    [lindex [buf$::eye::bufNo getkwd "CDELT2"] 1]

   }

