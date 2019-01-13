#
# Fichier : configuration.tcl
# Description : Acquisition de flat sur le ciel - Observation en automatique
# Camera : Script optimise pour une Andor ikon-L
# Auteur : Frédéric Vachier
# Mise à jour $Id: configuration.tcl 11593 2015-02-22 21:33:11Z fredvachier $
#

   proc ::t1m_roue_a_filtre::init_roue { } {

      # Col : 0 Actif/NonActif
      # Col : 1 Nom court
      # Col : 2 Nom long
      # Col : 3 nbimage
      # Col : 4 sens de debut nuit
      # Col : 5 largeur (nm)
      # Col : 6 centre  (nm)
      # Col : 7 offset exptime
      #                                                0  1              2        3   4   5     6    7

      set ::t1m_roue_a_filtre::private(filtre,1) [list 0  "RG695 - Mask" "RGm"    0   3   94  873    0.]
      set ::t1m_roue_a_filtre::private(filtre,2) [list 0  "L - Mask"     "Lm"     0   4  108 1004    0.]
      set ::t1m_roue_a_filtre::private(filtre,3) [list 0  "CH4-890"      "Meth"   0   1   10  890    0.]
      set ::t1m_roue_a_filtre::private(filtre,4) [list 0  "807-Masque"   "807m"   0   6  200  907    0.]
      set ::t1m_roue_a_filtre::private(filtre,5) [list 0  "up_sloan"     "Up"     0   2   65  352    0.]
      set ::t1m_roue_a_filtre::private(filtre,6) [list 0  "gp_sloan"     "Gp"     0   9  149  475    0.]
      set ::t1m_roue_a_filtre::private(filtre,7) [list 0  "rp_sloan"     "Rp"     0   8  133  628    0.]
      set ::t1m_roue_a_filtre::private(filtre,8) [list 0  "ip_sloan"     "Ip"     0   7  149  769    0.]
      set ::t1m_roue_a_filtre::private(filtre,9) [list 0  "zp_sloan"     "Zp"     0   5  200  920    0.]

#     set ::t1m_roue_a_filtre::private(filtre,1) [list 0  "Large"      "L"      0   9   0.1   0.2   0.]
#     set ::t1m_roue_a_filtre::private(filtre,2) [list 0  "B"          "B"      0   8   0.1   0.2   0.]
#     set ::t1m_roue_a_filtre::private(filtre,3) [list 0  "V"          "V"      0   7   0.1   0.2   0.]
#     set ::t1m_roue_a_filtre::private(filtre,4) [list 0  "R"          "R"      0   6   0.1   0.2   0.]
#     set ::t1m_roue_a_filtre::private(filtre,1) [list 0  "Z_s_Sloan"  "Zs"     0   3   94   873    0.]
#     set ::t1m_roue_a_filtre::private(filtre,2) [list 0  "Y_Sloan"    "Y"      0   4  108  1004    0.]
   }

