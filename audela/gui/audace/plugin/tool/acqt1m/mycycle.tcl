#
# Fichier : mycycle.tcl
# Description : Procedure de definition des cylces personnels
# Auteur : Frédéric Vachier
# Mise à jour $Id: mycycle.tcl 11138 2014-11-11 10:47:47Z robertdelmas $
#
# source audace/plugin/tool/acqt1m/cycle.tcl
#

#============================================================
# Declaration du namespace bddimages
#    initialise le namespace
#============================================================
namespace eval ::mycycle {


   proc ::mycycle::use { } {

      ::mycycle::snovae

   }


   proc ::mycycle::KOI13 { } {

      variable private

      set private(object)         "KOI-13"
      set private(bin)            "1x1"
      set private(ra)             "19:07:53.09"
      set private(dec)            "+46:52:6.10"
      # Liste le mouvement de la roue, [Filtre Exposure nbimg]
      set private(roue)           [list [list "Us" 60 1] [list "Gs" 3 5] [list "Rs" 1.5 10] [list "Is" 1.5 10] [list "Zs" 3 5] ]

   }


   proc ::mycycle::Comete { } {

      variable private

      set ::cycle::object          "67P"
      set ::cycle::ra              "19:07:53.09"
      set ::cycle::dec             "+46:52:6.10"


      # Liste le mouvement de la roue, [Filtre Exposure nbimg]
      set private(roue)           [list [list "Us" 60 1] [list "Gs" 3 5] [list "Rs" 1.5 10] [list "Is" 1.5 10] [list "Zs" 3 5] ]
   }


   proc ::mycycle::Haumea { } {

      set ::cycle::object         "Haumea"
      set ::cycle::ra             "13 53 11.8619"
      set ::cycle::dec            "+18 35 49.413"

      # Liste le mouvement de la roue  [Filtre    Exposure   nbimg   binning   ]
      set ::cycle::roue          [list [list "Rs"   150        1        1      ] \
                                       [list "Is"   150        1        1      ] \
                                       [list "Gs"   150        1        1      ] \
                                       [list "Rs"   60        1        2      ] \
                                       [list "Is"   60        1        2      ] \
                                       [list "Gs"   60        1        2      ] \
                                 ]

   }


   proc ::mycycle::TNO { } {

      set ::cycle::object         "2005_UQ513"
      set ::cycle::ra             "21 59 49"
      set ::cycle::dec            "3 8 55"

      # Liste le mouvement de la roue  [Filtre    Exposure   nbimg   binning   ]
      set ::cycle::roue          [list [list "Rs"   90        1        1      ] \
                                       [list "Rs"   300         1        1      ] \
                                 ]

   }


   proc ::mycycle::snovae { } {

      set ::cycle::object         "SN"
      set ::cycle::ra             "11 29 3"
      set ::cycle::dec            "17 14 19.41"

      # Liste le mouvement de la roue  [Filtre    Exposure   nbimg   binning   ]
      set ::cycle::roue          [list [list "Rs"   600         1        1      ] \
                                       [list "B"    900         1        1      ] \
                                       [list "V"    900         1        1      ] \
                                 ]

   }


# Fin namespace
}

