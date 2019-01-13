##
# @file photometrie_if.tcl
#
# @author Jacques Michelet (jacques.michelet@aquitania.org)
#
# @brief Outil pour l'analyse photométrique d'une image.
#
# $Id: photometrie_if.tcl 12679 2016-01-15 21:32:22Z robertdelmas $
#

namespace eval ::Photometrie {
    package provide photometrie 2.0

    source [ file join [ file dirname [ info script ] ] photometrie.cap ]
    source [ file join [ file dirname [ info script ] ] photometrie.tcl ]

    #------------------------------------------------------------
    # getPluginTitle
    #    retourne le titre du plugin dans la langue de l'utilisateur
    #------------------------------------------------------------
    proc getPluginTitle { } {
      variable photometrie_texte

      return "$photometrie_texte(titre_menu)"
    }

    #------------------------------------------------------------
    # getPluginHelp
    #    retourne le nom du fichier d'aide principal
    #------------------------------------------------------------
    proc getPluginHelp { } {
        return ""
    }

    #------------------------------------------------------------
    # getPluginType
    #    retourne le type de plugin
    #------------------------------------------------------------
    proc getPluginType { } {
        return "tool"
    }

    #------------------------------------------------------------
    # getPluginDirectory
    #    retourne le nom du repertoire du plugin
    #------------------------------------------------------------
    proc getPluginDirectory { } {
        return "photometry"
        }

    #------------------------------------------------------------
    # getPluginOS
    #    retourne le ou les OS de fonctionnement du plugin
    #------------------------------------------------------------
    proc getPluginOS { } {
        return [ list Linux Windows ]
    }

    #------------------------------------------------------------
    # getPluginProperty
    #    retourne la valeur de la propriete
    #
    # parametre :
    #    propertyName : nom de la propriete
    # return : valeur de la propriete ou "" si la propriete n'existe pas
    #------------------------------------------------------------
    proc getPluginProperty { propertyName } {
        switch $propertyName {
            function     { return "analysis" }
            subfunction1 { return "photometry" }
            display      { return "window" }
        }
    }

    #------------------------------------------------------------
    # createPluginInstance
    #    cree une nouvelle instance de l'outil
    #------------------------------------------------------------
    proc createPluginInstance { base { visuNo 1 } } {
        variable This

        #--- Inititalisation du nom de la fenetre
        set This "$base.photometrie_auto_manuel"

        if { [ catch { load libjm[info sharedlibextension]} erreur ] } {
            ::console::affiche_erreur "$erreur \n"
            return 1
        }

        if { [ catch { jm_versionlib } version_lib ] } {
            ::console::affiche_erreur "$version_lib \n"
            return 1
        } else {
            if { [ expr double( [ string range $version_lib 0 2 ] ) ] < 4.2 } {
                ::console::affiche_erreur "LibJM version must be greater than 4.2\n"
                return 1
            }
        }

        #--- J'ouvre la fenetre
        ::Photometrie::Principal

        #---
        return "NOP"
   }

    #------------------------------------------------------------
    # deletePluginInstance
    #    suppprime l'instance du plugin
    #------------------------------------------------------------
    proc deletePluginInstance { visuNo } {

    }

}

