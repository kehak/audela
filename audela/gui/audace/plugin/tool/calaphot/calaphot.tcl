##
# @file calaphot.tcl
#
# @author Olivier Thizy (thizy@free.fr) & Jacques Michelet (jacques.michelet@laposte.net)
#
# @brief Script pour la photométrie d'asteroides ou d'etoiles variables.
#
# $Id: calaphot.tcl 14211 2017-04-30 11:46:24Z jacquesmichelet $
#

namespace eval ::CalaPhot {
    package provide calaphot 7.4
    #   package require BLT
    source [ file join [ file dirname [ info script ] ] calaphot_cap.tcl ]
    source [ file join [ file dirname [ info script ] ] calaphot_graph.tcl ]
    source [ file join [ file dirname [ info script ] ] calaphot_calcul.tcl ]
    source [ file join [ file dirname [ info script ] ] calaphot_sex.tcl ]
#    source [ file join [ file dirname [ info script ] ] calaphot_catalogues.tcl ]
    source [ file join [ file dirname [ info script ] ] calaphot_principal.tcl ]

    #------------------------------------------------------------
    # getPluginTitle
    #    retourne le titre du plugin dans la langue de l'utilisateur
    #------------------------------------------------------------
    proc getPluginTitle { } {
        variable calaphot

        return "$calaphot(texte,titre_menu)"
    }

    #------------------------------------------------------------
    # getPluginHelp
    #    retourne le nom du fichier d'aide principal
    #------------------------------------------------------------
    proc getPluginHelp { } {
        return "calaphot.htm"
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
        return "calaphot"
    }

    #------------------------------------------------------------
    # getPluginOS
    #    retourne le ou les OS de fonctionnement du plugin
    #------------------------------------------------------------
    proc getPluginOS { } {
        return [ list Windows Linux Darwin ]
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
            subfunction1 { return "photometry_time_serie" }
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
        set This "$base"

        if {[catch {load libjm[info sharedlibextension]} erreur]} {
            ::console::affiche_erreur "$erreur \n"
            return 1
        }

        if {[catch {jm_versionlib} version_lib]} {
            ::console::affiche_erreur "$version_lib \n"
            return 1
        } else {
            if {[expr double([string range $version_lib 0 2])] < 3.0} {
                ::console::affiche_erreur "LibJM version must be greater than 3.0\n"
                return 1
            }
        }
        package require BLT
        package require BWidget
        package require http

        #--- J'ouvre la fenetre
        ::CalaPhot::Principal

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

