## @file astroid/votable.tcl
# Routines de gestion des votables

## Ecriture de la votable \n
# \c listsources :: param[in] :: structure de type sources \n
# \c tabkey      :: param[in] :: Chaine de caractere du nom du fichier fits \n
# \c newcatafile :: param[in] :: Chaine de caractere du nom du fichier cata

proc write_cata_votable { listsources tabkey newcatafile } {

   global bddconf

   set listevotable [listesource2listevotable $listsources $tabkey $newcatafile]

}


proc listesource2listevotable { listsources tabkey newcatafile } {

 global bddconf

   set fields  [lindex $listsources 0]
   set sources [lindex $listsources 1]

   set  listevotable "<?xml version='1.0'?>\n"
   append listevotable "<VOTABLE xsi:schemaLocation=\"http://www.ivoa.net/xml/VOTable/v1.1 http://www.ivoa.net/xml/VOTable/v1.1\"\n"
   append listevotable "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n"
   append listevotable "xmlns=\"http://www.ivoa.net/xml/VOTable/v1.1\">\n"
   append listevotable "<RESSOURCE>\n"


 # TABLE HEADER
         set votable "<TABLE name=\"header\" nrows=\"nbheaderkey\">\n"
         
         # ecrire ici tout le header de l image depuis le $tabkey

         append votable "  </TABLEDATA>\n"
         append votable "  </DATA>\n"
         append votable "</TABLE>\n"

# TABLES SOURCES


   foreach s $fields {
      foreach {name commun col} $s {
         gren_info "INSERT $name\n"
         set nbcol [llength $col]
         gren_info "COL $nbcol\n"

         # Cles des header
         set listevotabletmp "  <FIELD datatype=\"char\" name=\"idcataspec\" arraysize=\"30\"/>\n"
         if {$nbcol>0} {
            foreach key $col {
               append listevotabletmp "  <FIELD datatype=\"char\" name=\"$key\" arraysize=\"30\"/>\n"
            }
         }
         append listevotabletmp "  <DATA>\n"
         append listevotabletmp "  <TABLEDATA>\n"
         # --
         set nrows 0
         set idcataspec 0
         foreach s $sources {
               foreach c $s {
                  if { [lindex $c 0]==$name } {
                     set d [lindex $c 2]
                     append listevotabletmp "    <TR>\n"
                     append listevotabletmp "      <TD>$idcataspec</TD>\n"
                     if {$nbcol>0} {
                        foreach a $d {
                           append listevotabletmp "      <TD>$a</TD>\n"
                        }
                     }
                     append listevotabletmp "    </TR>\n"
                     incr nrows
                  } 
               }
            incr idcataspec
            #if { $nrows >= 5 } { break }
         }
         append listevotable "<TABLE name=\"$name\" nrows=\"$nrows\">\n"
         append listevotable $listevotabletmp
         append listevotable "  </TABLEDATA>\n"
         append listevotable "  </DATA>\n"
         append listevotable "</TABLE>\n"
      }
   }
   append listevotable "</RESSOURCE>\n"
   append listevotable "</VOTABLE>\n"

   set fxml [open $newcatafile "w"]
   puts $fxml $listevotable
   close $fxml

   return 0


}








proc write_cata_votable_dom { listsources } {

 global bddconf

   gren_info "GO WRITE VOTABLE \n"

   set newcatafile [file join $bddconf(astroid) .. ssp_votable cata.xml ]


   set docxml [::dom::DOMImplementation create]

   # Cree la racine du document 
   set root [::dom::document createElement $docxml "VOTABLE"]
   ::dom::element setAttribute $root "xmlns:xsi" "http://www.w3.org/2001/XMLSchema-instance"
   ::dom::element setAttribute $root "xsi:schemaLocation" "http://www.ivoa.net/xml/VOTable/v1.1 http://www.ivoa.net/xml/VOTable/v1.1"
   ::dom::element setAttribute $root "xmlns" "http://www.ivoa.net/xml/VOTable/v1.1"

   set ressource [::dom::document createElement $root "RESSOURCE"]


   # Premiere TABLE : La table Header
   set tableheader [::dom::document createElement $ressource "TABLE"]
   ::dom::element setAttribute $tableheader "nrows" 2
   ::dom::element setAttribute $tableheader "name" "Header"

      # Cles des header
      set node [::dom::document createElement $tableheader "FIELD"]
      ::dom::element setAttribute $node "comment"   "Telescope name"
      ::dom::element setAttribute $node "unit"      "iso-8601"
      ::dom::element setAttribute $node "name"      "TELESCOP"
      ::dom::element setAttribute $node "datatype"  "char"
      ::dom::element setAttribute $node "arraysize" "30"
      set node [::dom::document createElement $tableheader "FIELD"]
      ::dom::element setAttribute $node "comment"   "Observation date and time"
      ::dom::element setAttribute $node "unit"      "iso-8601"
      ::dom::element setAttribute $node "name"      "DATE-OBS"
      ::dom::element setAttribute $node "datatype"  "datetime"
      ::dom::element setAttribute $node "arraysize" "25"

       # --
       set data [::dom::document createElement $tableheader "DATA"]
       set tabledata [::dom::document createElement $data "TABLEDATA"]
      
          # les Donnees
          set tr [::dom::document createElement $tabledata "TR"]
          set key [::dom::document createElement $tr "TD"]
          ::dom::document createTextNode $key "Tarot_Chili"
          set key [::dom::document createElement $tr "TD"]
          ::dom::document createTextNode $key "2011-06-23T23:23:23.2345"


   

   if {1} {       

   # TABLES : les Sources de l'image
       
   set fields  [lindex $listsources 0]
   set sources [lindex $listsources 1]
       
   foreach s $fields {
      foreach {name commun col} $s {
         gren_info "INSERT $name\n"
         
         set table [::dom::document createElement $ressource "TABLE"]
         ::dom::element setAttribute $table "nrows" 3
         ::dom::element setAttribute $table "name" "$name"

         # Cles des header
         foreach key $col {
         set node [::dom::document createElement $table "FIELD"]
         ::dom::element setAttribute $node "name"      "$key"
         ::dom::element setAttribute $node "datatype"  "char"
         ::dom::element setAttribute $node "arraysize" "30"
         }
         # --
         set data [::dom::document createElement $table "DATA"]
         set tabledata [::dom::document createElement $data "TABLEDATA"]
         
         set cpt 0
         foreach s $sources {
            set tr [::dom::document createElement $tabledata "TR"]
            foreach c $s {
               if { [lindex $c 0]==$name } {
                  set d [lindex $c 2]
                  foreach a $d {
                     set key [::dom::document createElement $tr "TD"]
                     ::dom::document createTextNode $key $a
                  } 
               } 
            }
            if { $cpt > 3 } { break }
            incr cpt
         }
         break
      }
      break
   }
       
   }  
       

   set fxml [open $newcatafile "w"]
   puts $fxml [::dom::DOMImplementation serialize $docxml -indent true]
   close $fxml

   return 0





}










## Lecture de la votable
proc read_cata_votable {  } {



}
