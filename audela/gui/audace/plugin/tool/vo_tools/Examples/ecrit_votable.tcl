#
# Fichier : votable_example.tcl
# Description : Exemple d'ecriture d'une VOTable
#     source /usr/local/src/audela/gui/audace/plugin/tool/vo_tools/Examples/ecrit_votable.tcl
# Auteur : Jerome BERTHIER
# Mise à jour $Id: ecrit_votable.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votable.tcl ]\""
namespace import votable::*

# Instantiation de la VOTable, version 1.2 avec prefixe 'vot'
set votable [::votable::init "1.2" "vot:"]

# XSL style sheet "myXSLStyleSheet.xsl"
set ::votable::xsluri "myXSLStyleSheet.xsl"
# URI du data model STC
set ::votable::dataModelNS "http://www.ivoa.net/xml/STC"
# Prefixe du data model STC
set ::votable::dataModelPrefix "stc"

# Ouverture de la VOTable
set v [::votable::openVOTable]

# Ajout d'elements INFO
set attr [list [list $::votable::Info::ID "reqTarget"] [list $::votable::Info::NAME "-c"] [list $::votable::Info::VALUE "xxx,rm=1"]]
set v [join [list $v [::votable::addElement $::votable::Element::INFO $attr ""]] ""]
set attr [list [list $::votable::Info::ID "reqEpoch"] [list $::votable::Info::NAME "-ep"] [list $::votable::Info::VALUE "yyy"]]
set v [join [list $v [::votable::addElement $::votable::Element::INFO $attr ""]] ""]

# Ajout d'elements GROUP, used to define the space-time reference frame of the spherical coordinates
set attr [list [list $::votable::Group::UTYPE "stc:AstroCoordSystem"] [list $::votable::Group::ID "IMCCE-INPOP-GEO"]]
set v [join [list $v [::votable::openElement $::votable::Element::GROUP $attr]] ""]
# -- Times refer to UTC
set attr [list [list $::votable::Group::UTYPE "stc:AstroCoordSystem.TimeFrame"]]
set v [join [list $v [::votable::openElement $::votable::Element::GROUP $attr]] ""]
set attr [list [list $::votable::Param::ID "TimeScale"] [list $::votable::Param::NAME "TimeScale"] [list $::votable::Param::DATATYPE "char"] [list $::votable::Param::ARRAYSIZE "*"] [list $::votable::Param::UTYPE "stc:AstroCoordSystem.TimeFrame.TimeScale"] [list $::votable::Param::VALUE "UTC"]]
set v [join [list $v [::votable::addParamElement $attr "" "" ""]] ""]
set attr [list [list $::votable::Param::ID "RefPosition"] [list $::votable::Param::NAME "RefPosition"] [list $::votable::Param::DATATYPE "char"] [list $::votable::Param::ARRAYSIZE "*"] [list $::votable::Param::UTYPE "stc:AstroCoordSystem.TimeFrame.ReferencePosition"] [list $::votable::Param::VALUE "GEOCENTER"]]
set v [join [list $v [::votable::addParamElement $attr "" "" ""]] ""]
set v [join [list $v [::votable::closeElement $::votable::Element::GROUP]] ""]
# -- Reference frame
set attr [list [list $::votable::Group::UTYPE "stc:AstroCoordSystem.SpaceFrame"]]
set v [join [list $v [::votable::openElement $::votable::Element::GROUP $attr]] ""]
set attr [list [list $::votable::Param::ID "CooFrame"] [list $::votable::Param::NAME "CooFrame"] [list $::votable::Param::DATATYPE "char"] [list $::votable::Param::ARRAYSIZE "*"] [list $::votable::Param::UTYPE "stc:AstroCoordSystem.SpaceFrame.CoordRefFrame"] [list $::votable::Param::VALUE "ICRS"]]
set v [join [list $v [::votable::addParamElement $attr "" "" ""]] ""]
set attr [list [list $::votable::Param::ID "CooFrameOrigin"] [list $::votable::Param::NAME "CooFrameOrigin"] [list $::votable::Param::DATATYPE "char"] [list $::votable::Param::ARRAYSIZE "*"] [list $::votable::Param::UTYPE "stc:AstroCoordSystem.SpaceFrame.ReferencePosition"] [list $::votable::Param::VALUE "GEOCENTER"]]
set v [join [list $v [::votable::addParamElement $attr "" "" ""]] ""]
set attr [list [list $::votable::Param::ID "Ephemeris"] [list $::votable::Param::NAME "Ephemeris"] [list $::votable::Param::DATATYPE "char"] [list $::votable::Param::ARRAYSIZE "*"] [list $::votable::Param::UTYPE "stc:AstroCoordSystem.SpaceFrame.ReferencePosition.PlanetaryEphem"] [list $::votable::Param::VALUE "IMCCE-INPOP"]]
set v [join [list $v [::votable::addParamElement $attr "Planetary theory used to compute the ephemeris" "" ""]] ""]
set attr [list [list $::votable::Param::ID "CooType"] [list $::votable::Param::NAME "CooType"] [list $::votable::Param::DATATYPE "char"] [list $::votable::Param::ARRAYSIZE "*"] [list $::votable::Param::UTYPE "stc:AstroCoordSystem.SpaceFrame.CoordFlavor"] [list $::votable::Param::VALUE "SPHERICAL"]]
set v [join [list $v [::votable::addParamElement $attr "Planetary theory used to compute the ephemeris" "" ""]] ""]
set attr [list [list $::votable::Param::ID "Naxes"] [list $::votable::Param::NAME "Naxes"] [list $::votable::Param::DATATYPE "char"] [list $::votable::Param::ARRAYSIZE "*"] [list $::votable::Param::UTYPE "stc:AstroCoordSystem.SpaceFrame.coord_naxes"] [list $::votable::Param::VALUE "3"]]
set v [join [list $v [::votable::addParamElement $attr "Planetary theory used to compute the ephemeris" "" ""]] ""]
set v [join [list $v [::votable::closeElement $::votable::Element::GROUP]] ""]
set v [join [list $v [::votable::closeElement $::votable::Element::GROUP]] ""]

# Ouverture de l'element RESOURCE
set attr [list [list $::votable::Resource::NAME "skybot"] ]
set v [join [list $v [::votable::openResourceElement $attr]] ""]

# Ajout des elements PARAM
set attr [list [list $::votable::Param::ID "epoch"] [list $::votable::Param::NAME "Epoch"] [list $::votable::Param::DATATYPE "double"] [list $::votable::Param::UCD "time.epoch"] [list $::votable::Param::UNIT "d"] [list $::votable::Param::VALUE "2453384.92154"]]
set v [join [list $v [::votable::addParamElement $attr "" "" ""]] ""]
set attr [list [list $::votable::Param::ID "fovRA"] [list $::votable::Param::NAME "RA"] [list $::votable::Param::DATATYPE "double"] [list $::votable::Param::UCD "pos.eq.ra"] [list $::votable::Param::UNIT "deg"] [list $::votable::Param::VALUE "148.67"]]
set v [join [list $v [::votable::addParamElement $attr "" "" ""]] ""]
set attr [list [list $::votable::Param::ID "fovDEC"] [list $::votable::Param::NAME "DEC"] [list $::votable::Param::DATATYPE "double"] [list $::votable::Param::UCD "pos.eq.dec"] [list $::votable::Param::UNIT "deg"] [list $::votable::Param::VALUE "16.3838"]]
set v [join [list $v [::votable::addParamElement $attr "" "" ""]] ""]
set attr [list [list $::votable::Param::ID "fovSR"] [list $::votable::Param::NAME "fovRadius"] [list $::votable::Param::DATATYPE "double"] [list $::votable::Param::UCD "instr.fov"] [list $::votable::Param::UNIT "arcsec"] [list $::votable::Param::VALUE "1200.0"]]
set v [join [list $v [::votable::addParamElement $attr "" "" ""]] ""]
set attr [list [list $::votable::Param::ID "observer"] [list $::votable::Param::NAME "Observer"] [list $::votable::Param::DATATYPE "char"] [list $::votable::Param::ARRAYSIZE "*"] [list $::votable::Param::UCD "meta.code;obs.observer"] [list $::votable::Param::VALUE "500"]]
set v [join [list $v [::votable::addParamElement $attr "" "" ""]] ""]

# Ouverture de l'element TABLE
set attr [list [list $::votable::Table::ID "result"] [list $::votable::Table::NAME "EphemerisTable"]]
set v [join [list $v [::votable::openTableElement $attr]] ""]
# Ajout d'une description de la table
set v [join [list $v [::votable::addElement $::votable::Element::DESCRIPTION "" "Ephemeris of the solar system objects located in the FOV"]] ""]

# Definition de l'ephemeride fournie dans la table
set attr [list [list $::votable::Group::ID "Ephemeris"] [list $::votable::Group::UTYPE "stc:AstroCoords"] [list $::votable::Group::REF "IMCCE-INPOP-GEO"]]
set v [join [list $v [::votable::openElement $::votable::Element::GROUP $attr]] ""]
set attr [list [list $::votable::Param::NAME "GeoCoordinates"] [list $::votable::Param::DATATYPE "char"] [list $::votable::Param::ARRAYSIZE "*"] [list $::votable::Param::UTYPE "stc:AstroCoords.coord_sys_id"] [list $::votable::Param::VALUE "UTC-ICRS-GEO"]]
set v [join [list $v [::votable::addParamElement $attr "" "" ""]] ""]
set v [join [list $v [::votable::closeElement $::votable::Element::GROUP]] ""]

# Ajout des elements FIELD avec reference a la definition du systeme de coordonnees
set attr [list [list $::votable::Field::ID "num"] [list $::votable::Field::NAME "Num"] [list $::votable::Field::UCD "meta.id;meta.number"] [list $::votable::Field::DATATYPE "char"] [list $::votable::Field::ARRAYSIZE "6"] [list $::votable::Field::WIDTH "6"]]
set v [join [list $v [::votable::addFieldElement $attr "Solar system object number" "" ""]] ""]
set attr [list [list $::votable::Field::ID "name"] [list $::votable::Field::NAME "Name"] [list $::votable::Field::UCD "meta.id;meta.main"] [list $::votable::Field::DATATYPE "char"] [list $::votable::Field::ARRAYSIZE "32"] [list $::votable::Field::WIDTH "32"]]
set link [list [list $::votable::Link::HREF "http://vizier.u-strasbg.fr/cgi-bin/VizieR-5?-source=B/astorb/astorb&amp;Name===\$\{Name\}"]]
set v [join [list $v [::votable::addFieldElement $attr "Solar system object name" "" $link]] ""]
set attr [list [list $::votable::Field::ID "ra"] [list $::votable::Field::NAME "RA"] [list $::votable::Field::UCD "pos.eq.ra;meta.main"] [list $::votable::Field::DATATYPE "char"] [list $::votable::Field::ARRAYSIZE "13"] [list $::votable::Field::WIDTH "13"] [list $::votable::Field::UNIT "h:m:s"] [list $::votable::Field::REF "Ephemeris"] [list $::votable::Field::UTYPE "stc:AstroCoords.Position3D.Value3.C1"]]
set v [join [list $v [::votable::addFieldElement $attr "Astrometric J2000 right ascension" "" ""]] ""]
set attr [list [list $::votable::Field::ID "dec"] [list $::votable::Field::NAME "DEC"] [list $::votable::Field::UCD "pos.eq.dec;meta.main"] [list $::votable::Field::DATATYPE "char"] [list $::votable::Field::ARRAYSIZE "13"] [list $::votable::Field::WIDTH "13"] [list $::votable::Field::UNIT "d:m:s"] [list $::votable::Field::REF "Ephemeris"] [list $::votable::Field::UTYPE "stc:AstroCoords.Position3D.Value3.C2"]]
set v [join [list $v [::votable::addFieldElement $attr "Astrometric J2000 right declination" "" ""]] ""]
set attr [list [list $::votable::Field::ID "magV"] [list $::votable::Field::NAME "Mv"] [list $::votable::Field::UCD "em.opt.V"] [list $::votable::Field::DATATYPE "float"] [list $::votable::Field::WIDTH "13"] [list $::votable::Field::PRECISION "2"]]
set v [join [list $v [::votable::addFieldElement $attr "Visual magnitude" "" ""]] ""]
set attr [list [list $::votable::Field::ID "dgeo"] [list $::votable::Field::NAME "Dg"] [list $::votable::Field::UCD "phys.distance"] [list $::votable::Field::DATATYPE "double"] [list $::votable::Field::WIDTH "15"] [list $::votable::Field::UNIT "AU"] [list $::votable::Field::REF "Ephemeris"] [list $::votable::Field::UTYPE "stc:AstroCoords.Position3D.Value3.C3"]]
set v [join [list $v [::votable::addFieldElement $attr "Distance from observer" "" ""]] ""]

# Ouverture de l'element DATA
set v [join [list $v [::votable::openElement $::votable::Element::DATA ""]] ""]
# Ouverture de l'element TABLEDATA
set v [join [list $v [::votable::openElement $::votable::Element::TABLEDATA ""]] ""]

# Ajout des elements dans la table (TR/TD)
set v [join [list $v [::votable::openElement $::votable::Element::TR ""]] ""]
set v [join [list $v [::votable::addTD "2895"]] ""]
set v [join [list $v [::votable::addTD "Memnon"]] ""]
set v [join [list $v [::votable::addTD "09 54 40.2046"]] ""]
set v [join [list $v [::votable::addTD "+16 23 01.633"]] ""]
set v [join [list $v [::votable::addTD "16.6"]] ""]
set v [join [list $v [::votable::addTD "4.347530676"]] ""]
set v [join [list $v [::votable::closeElement $::votable::Element::TR]] ""]
# --
set v [join [list $v [::votable::openElement $::votable::Element::TR ""]] ""]
set v [join [list $v [::votable::addTD "-"]] ""]
set v [join [list $v [::votable::addTD "2007 TP12"]] ""]
set v [join [list $v [::votable::addTD "09 54 42.1509"]] ""]
set v [join [list $v [::votable::addTD "+16 22 36.198"]] ""]
set v [join [list $v [::votable::addTD "20.3"]] ""]
set v [join [list $v [::votable::addTD "1.664499989"]] ""]
set v [join [list $v [::votable::closeElement $::votable::Element::TR]] ""]
# --
set v [join [list $v [::votable::openElement $::votable::Element::TR ""]] ""]
set v [join [list $v [::votable::addTD "-"]] ""]
set v [join [list $v [::votable::addTD "2005 CJ35"]] ""]
set v [join [list $v [::votable::addTD "09 54 45.8479"]] ""]
set v [join [list $v [::votable::addTD "+16 22 10.717"]] ""]
set v [join [list $v [::votable::addTD "20.6"]] ""]
set v [join [list $v [::votable::addTD "2.363300870"]] ""]
set v [join [list $v [::votable::closeElement $::votable::Element::TR]] ""]
# --
set v [join [list $v [::votable::openElement $::votable::Element::TR ""]] ""]
set v [join [list $v [::votable::addTD "70783"]] ""]
set v [join [list $v [::votable::addTD "1999 VK44"]] ""]
set v [join [list $v [::votable::addTD "09 54 34.3801"]] ""]
set v [join [list $v [::votable::addTD "+16 24 55.671"]] ""]
set v [join [list $v [::votable::addTD "19.0"]] ""]
set v [join [list $v [::votable::addTD "1.683169804"]] ""]
set v [join [list $v [::votable::closeElement $::votable::Element::TR]] ""]

## etc.

# Fermeture de l'element TABLEDATA
set v [join [list $v [::votable::closeElement $::votable::Element::TABLEDATA]] ""]
# Fermeture de l'element DATA
set v [join [list $v [::votable::closeElement $::votable::Element::DATA]] ""]
# Fermeture de l'element TABLE
set v [join [list $v [::votable::closeTableElement]] ""]
# Fermeture de l'element RESOURCE
set v [join [list $v [::votable::closeResourceElement]] ""]

# Fermeture de la VOTable
set v [join [list $v [::votable::closeVOTable]] ""]

# Affichage de la VOTABLE
::console::affiche_resultat $v
