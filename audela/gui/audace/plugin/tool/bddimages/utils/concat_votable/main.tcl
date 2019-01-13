### source [ file join $audace(rep_plugin) tool bddimages utils concat_votable main.tcl]

set file1 [ file join $audace(rep_plugin) tool bddimages utils concat_votable votable1.xml]

gren_info "Chargement 1ere votable\n"

::votableUtil::loadVotable $file1
set err [catch {::votableUtil::getVotable} xml]
set votable [::dom::parse $xml]

set vtab(info,id)    [::dom::node stringValue [::dom::selectNode $votable {descendant::INFO/attribute::ID}]]
set vtab(info,name)  [::dom::node stringValue [::dom::selectNode $votable {descendant::INFO/attribute::name}]]
set vtab(info,value) [::dom::node stringValue [::dom::selectNode $votable {descendant::INFO/attribute::value}]]


foreach param [::dom::selectNode $votable {descendant::PARAM}] {
   set id  [::dom::node stringValue [::dom::selectNode $param {attribute::ID}]]
   set vtab(param,$id,desc) [::dom::node stringValue [::dom::selectNode $param {DESCRIPTION/text()}]]
}



