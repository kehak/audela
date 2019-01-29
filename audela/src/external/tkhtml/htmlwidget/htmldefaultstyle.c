
#define HTML_DEFAULT_TCL \
        "#\n" \
        "# tkhtml.tcl --\n" \
        "#\n" \
        "#     This file contains:\n" \
        "#\n" \
        "#         - The default bindings for the Html widget, and\n" \
        "#         - Some Tcl functions used by the stylesheet html.css.\n" \
        "#\n" \
        "# ------------------------------------------------------------------------\n" \
        "#\n" \
        "# Copyright (c) 2005 Eolas Technologies Inc.\n" \
        "# All rights reserved.\n" \
        "# \n" \
        "# This Open Source project was made possible through the financial support\n" \
        "# of Eolas Technologies Inc.\n" \
        "# \n" \
        "# Redistribution and use in source and binary forms, with or without\n" \
        "# modification, are permitted provided that the following conditions are met:\n" \
        "# \n" \
        "#     * Redistributions of source code must retain the above copyright\n" \
        "#       notice, this list of conditions and the following disclaimer.\n" \
        "#     * Redistributions in binary form must reproduce the above copyright\n" \
        "#       notice, this list of conditions and the following disclaimer in the\n" \
        "#       documentation and/or other materials provided with the distribution.\n" \
        "#     * Neither the name of the <ORGANIZATION> nor the names of its\n" \
        "#       contributors may be used to endorse or promote products derived from\n" \
        "#       this software without specific prior written permission.\n" \
        "# \n" \
        "# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\"\n" \
        "# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE\n" \
        "# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE\n" \
        "# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE\n" \
        "# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR\n" \
        "# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF\n" \
        "# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS\n" \
        "# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN\n" \
        "# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)\n" \
        "# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE\n" \
        "# POSSIBILITY OF SUCH DAMAGE.\n" \
        "#\n" \
        "\n" \
        "# Default bindings\n" \
        "#\n" \
        "# bind Html <ButtonPress>     { focus %W }\n" \
        "bind Html <KeyPress-Up>     { %W yview scroll -1 units }\n" \
        "bind Html <KeyPress-Down>   { %W yview scroll  1 units }\n" \
        "bind Html <KeyPress-Return> { %W yview scroll  1 units }\n" \
        "bind Html <KeyPress-Right>  { %W xview scroll  1 units }\n" \
        "bind Html <KeyPress-Left>   { %W xview scroll -1 units }\n" \
        "bind Html <KeyPress-Next>   { %W yview scroll  1 pages }\n" \
        "bind Html <KeyPress-space>  { %W yview scroll  1 pages }\n" \
        "bind Html <KeyPress-Prior>  { %W yview scroll -1 pages }\n" \
        "\n" \
        "switch -- $::tcl_platform(platform) {\n" \
        "  windows {\n" \
        "    bind Html <MouseWheel>   { %W yview scroll [expr %D/-30] units }\n" \
        "  }\n" \
        "  macintosh {\n" \
        "    bind Html <MouseWheel>   { %W yview scroll [expr %D*-4] units }\n" \
        "  }\n" \
        "  default {\n" \
        "    # Assume X windows by default.\n" \
        "    bind Html <ButtonPress-4>   { %W yview scroll -4 units }\n" \
        "    bind Html <ButtonPress-5>   { %W yview scroll  4 units }\n" \
        "  }\n" \
        "}\n" \
        "\n" \
        "\n" \
        "# Some Tcl procs used by html.css\n" \
        "#\n" \
        "namespace eval tkhtml {\n" \
        "    proc len {val} {\n" \
        "        if {[regexp {^[0-9]+$} $val]} {\n" \
        "            append val px\n" \
        "        }\n" \
        "        return $val\n" \
        "    }\n" \
        "\n" \
        "    proc color {val} {\n" \
        "        set len [string length $val]\n" \
        "        if {0==($len % 3) && [regexp {^[0-9a-fA-F]*$} $val]} {\n" \
        "            return \"#$val\"\n" \
        "        }\n" \
        "        return $val\n" \
        "    }\n" \
        "\n" \
        "    swproc attr {attr {len 0 1} {color 0 1}} {\n" \
        "        upvar N node\n" \
        "        set val [$node attr -default \"\" $attr]\n" \
        "        if {$val == \"\"}    {error \"\"}\n" \
        "        if {$len}          {return [len $val]}\n" \
        "        if {$color}        {return [color $val]}\n" \
        "        return $val\n" \
        "    }\n" \
        "\n" \
        "    # This is called for <input type=text> tags that have a size\n" \
        "    # attribute. The size attribute in this case is supposed to be\n" \
        "    # the width in characters.\n" \
        "    proc inputsize_to_css {} {\n" \
        "        upvar N node\n" \
        "        set size [$node attr size]\n" \
        "        catch {\n" \
        "          if {$size < 0} {error \"Bad value for size attribute\"}\n" \
        "        }\n" \
        "\n" \
        "        # Figure out if we are talking characters or pixels:\n" \
        "        switch -- [string tolower [$node attr -default text type]] {\n" \
        "          text     { set units ex }\n" \
        "          password { set units ex }\n" \
        "          default  { set units px }\n" \
        "        }\n" \
        "\n" \
        "        return \"${size}${units}\"\n" \
        "    }\n" \
        "    \n" \
        "    # The following two procs are used to determine the width and height of\n" \
        "    # <textarea> markups. Technically speaking, the \"cols\" and \"rows\"\n" \
        "    # attributes are compulsory for <textarea> elements.\n" \
        "    proc textarea_width {} {\n" \
        "        upvar N node\n" \
        "        set cols [$node attr -default \"\" cols]\n" \
        "        if {[regexp {[[:digit:]]+}] $cols} { return \"${cols}ex\" }\n" \
        "        return $cols\n" \
        "    }\n" \
        "    proc textarea_height {} {\n" \
        "        upvar N node\n" \
        "        set rows [$node attr -default \"\" rows]\n" \
        "        if {[regexp {[[:digit:]]+} $rows]} { return \"[expr ${rows} * 1.2]em\" }\n" \
        "        return $rows\n" \
        "    }\n" \
        "\n" \
        "    proc size_to_fontsize {} {\n" \
        "        upvar N node\n" \
        "        set size [$node attr size]\n" \
        "\n" \
        "        if {![regexp {([+-]?)([0123456789]+)} $size dummy sign quantity]} {\n" \
        "          error \"not an integer\"\n" \
        "        }\n" \
        "\n" \
        "        if {$sign eq \"\"} {\n" \
        "            switch -- $quantity {\n" \
        "                1 {return xx-small}\n" \
        "                2 {return small}\n" \
        "                3 {return medium}\n" \
        "                4 {return large}\n" \
        "                5 {return x-large}\n" \
        "                6 {return xx-large}\n" \
        "                default { error \"out of range: $size\" }\n" \
        "            }\n" \
        "        }\n" \
        "\n" \
        "        if {$sign eq \"-\"} {\n" \
        "            if {$quantity eq \"1\"} {return smaller}\n" \
        "            return \"[expr 100 * pow(0.85, $quantity)]%\"\n" \
        "        }\n" \
        "\n" \
        "        if {$sign eq \"+\"} {\n" \
        "            if {$quantity eq \"1\"} {return larger}\n" \
        "            return \"[expr 100 * pow(1.176, $quantity)]%\"\n" \
        "        }\n" \
        "\n" \
        "        error \"logic error\"\n" \
        "    }\n" \
        "\n" \
        "    swproc aa {tag attr {len 0 1} {if NULL} {color 0 1}} {\n" \
        "        upvar N node\n" \
        "        for {} {$node != \"\"} {set node [$node parent]} {\n" \
        "            if {[$node tag] == $tag} {\n" \
        "                if {[catch {$node attr $attr} val]} {error \"\"}\n" \
        "\n" \
        "                if {$if != \"NULL\"} {return $if}\n" \
        "                if {$val == \"\"}    {error \"\"}\n" \
        "                if {$len}          {return [len $val]}\n" \
        "                if {$color}        {return [color $val]}\n" \
        "                return $val\n" \
        "            }\n" \
        "        }\n" \
        "        error \"No such ancestor attribute: $tag $attr\"\n" \
        "    }\n" \
        "\n" \
        "    proc vscrollbar {base node} {\n" \
        "      set sb [scrollbar ${base}.vsb_[string map {: _} $node]]\n" \
        "      $sb configure -borderwidth 1 -highlightthickness 0 -command \"$node yview\"\n" \
        "      return $sb\n" \
        "    }\n" \
        "    proc hscrollbar {base node} {\n" \
        "      set sb [scrollbar ${base}.hsb_[string map {: _} $node] -orient horiz]\n" \
        "      $sb configure -borderwidth 1 -highlightthickness 0 -command \"$node xview\"\n" \
        "      return $sb\n" \
        "    }\n" \
        "}\n" \
        "\n" \
        "\n" \



#define HTML_DEFAULT_CSS \
        "/* Display types for non-table items. */\n" \
        "  ADDRESS, BLOCKQUOTE, BODY, DD, DIV, DL, DT, FIELDSET, \n" \
        "  FRAME, FRAMESET, H1, H2, H3, H4, H5, H6, NOFRAMES, \n" \
        "  OL, P, UL, APPLET, CENTER, DIR, HR, MENU, PRE, FORM\n" \
        "                { display: block }\n" \
        "\n" \
        "HEAD, SCRIPT, TITLE { display: none }\n" \
        "BODY {\n" \
        "  margin:8px;\n" \
        "}\n" \
        "\n" \
        "/* Rules for unordered-lists */\n" \
        "LI                   { display: list-item }\n" \
        "UL[type=\"square\"]>LI { list-style-type : square } \n" \
        "UL[type=\"disc\"]>LI   { list-style-type : disc   } \n" \
        "UL[type=\"circle\"]>LI { list-style-type : circle } \n" \
        "LI[type=\"circle\"]    { list-style-type : circle }\n" \
        "LI[type=\"square\"]    { list-style-type : square }\n" \
        "LI[type=\"disc\"]      { list-style-type : disc   }\n" \
        "\n" \
        "OL, UL, DIR, MENU, DD  { padding-left: 40px ; margin-left: 1em }\n" \
        "\n" \
        "NOBR {\n" \
        "  white-space: nowrap;\n" \
        "}\n" \
        "\n" \
        "/* Map the 'align' attribute to the 'float' property. Todo: This should\n" \
        " * only be done for images, tables etc. \"align\" can mean different things\n" \
        " * for different elements.\n" \
        " */\n" \
        "TABLE[align=\"left\"]       { float:left } \n" \
        "TABLE[align=\"right\"]      { \n" \
        "    float:right; \n" \
        "    text-align: inherit;\n" \
        "}\n" \
        "TABLE[align=\"center\"]     { \n" \
        "    margin-left:auto; \n" \
        "    margin-right:auto; \n" \
        "    text-align:inherit;\n" \
        "}\n" \
        "IMG[align=\"left\"]         { float:left }\n" \
        "IMG[align=\"right\"]        { float:right }\n" \
        "\n" \
        "/* If the 'align' attribute was not mapped to float by the rules above, map\n" \
        " * it to 'text-align'. The rules above take precedence because of their\n" \
        " * higher specificity. \n" \
        " *\n" \
        " * Also the <center> tag means to center align things.\n" \
        " */\n" \
        "[align=\"center\"]  { text-align:center }\n" \
        "[align=\"right\"]   { text-align:right }\n" \
        "[align=\"left\"]    { text-align:left }\n" \
        "CENTER            { text-align: center }\n" \
        "\n" \
        "\n" \
        "/* Rules for unordered-lists */\n" \
        "/* Todo! */\n" \
        "\n" \
        "TD, TH {\n" \
        "  padding: 1px;\n" \
        "  border-bottom-color: grey60;\n" \
        "  border-right-color: grey60;\n" \
        "  border-top-color: grey25;\n" \
        "  border-left-color: grey25;\n" \
        "}\n" \
        "\n" \
        "/* For a horizontal line, use a table with no content. We use a table\n" \
        " * instead of a block because tables are laid out around floating boxes, \n" \
        " * whereas regular blocks are not.\n" \
        " */\n" \
        "/*\n" \
        "HR { \n" \
        "  display: table; \n" \
        "  border-top: 1px solid grey45;\n" \
        "  background: grey80;\n" \
        "  height: 1px;\n" \
        "  width: 100%;\n" \
        "  text-align: center;\n" \
        "  margin: 0.5em 0;\n" \
        "}\n" \
        "*/\n" \
        "\n" \
        "HR {\n" \
        "  display: block;\n" \
        "  border-top:    1px solid grey45;\n" \
        "  border-bottom: 1px solid grey80;\n" \
        "  margin: 0.5em auto 0.5em auto;\n" \
        "}\n" \
        "\n" \
        "/* Basic table tag rules. */\n" \
        "TABLE { \n" \
        "  display: table;\n" \
        "  border-spacing: 2px;\n" \
        "\n" \
        "  border-bottom-color: grey25;\n" \
        "  border-right-color: grey25;\n" \
        "  border-top-color: grey60;\n" \
        "  border-left-color: grey60;\n" \
        "\n" \
        "  /* <table> elements do not inherit text-align by default. Strictly\n" \
        "   * speaking, this rule should not be used with documents that\n" \
        "   * use the \"strict\" DTD. Or something.\n" \
        "   */\n" \
        "  text-align: left;\n" \
        "}\n" \
        "\n" \
        "TR              { display: table-row }\n" \
        "THEAD           { display: table-header-group }\n" \
        "TBODY           { display: table-row-group }\n" \
        "TFOOT           { display: table-footer-group }\n" \
        "COL             { display: table-column }\n" \
        "COLGROUP        { display: table-column-group }\n" \
        "TD, TH          { display: table-cell }\n" \
        "CAPTION         { display: table-caption }\n" \
        "TH              { font-weight: bolder; text-align: center }\n" \
        "CAPTION         { text-align: center }\n" \
        "\n" \
        "H1              { font-size: 2em; margin: .67em 0 }\n" \
        "H2              { font-size: 1.5em; margin: .83em 0 }\n" \
        "H3              { font-size: 1.17em; margin: 1em 0 }\n" \
        "H4, P,\n" \
        "BLOCKQUOTE, UL,\n" \
        "FIELDSET, \n" \
        "OL, DL, DIR,\n" \
        "MENU            { margin-top: 1.0em; margin-bottom: 1.0em }\n" \
        "H5              { font-size: .83em; line-height: 1.17em; margin: 1.67em 0 }\n" \
        "H6              { font-size: .67em; margin: 2.33em 0 }\n" \
        "H1, H2, H3, H4,\n" \
        "H5, H6, B,\n" \
        "STRONG          { font-weight: bolder }\n" \
        "BLOCKQUOTE      { margin-left: 40px; margin-right: 40px }\n" \
        "I, CITE, EM,\n" \
        "VAR, ADDRESS    { font-style: italic }\n" \
        "PRE, TT, CODE,\n" \
        "KBD, SAMP       { font-family: courier }\n" \
        "BIG             { font-size: 1.17em }\n" \
        "SMALL, SUB, SUP { font-size: .83em }\n" \
        "SUB             { vertical-align: sub }\n" \
        "SUP             { vertical-align: super }\n" \
        "S, STRIKE, DEL  { text-decoration: line-through }\n" \
        "OL              { list-style-type: decimal }\n" \
        "OL UL, UL OL,\n" \
        "UL UL, OL OL    { margin-top: 0; margin-bottom: 0 }\n" \
        "U, INS          { text-decoration: underline }\n" \
        "ABBR, ACRONYM   { font-variant: small-caps; letter-spacing: 0.1em }\n" \
        "\n" \
        "/* Formatting for <pre> etc. */\n" \
        "PRE, PLAINTEXT, XMP { \n" \
        "  display: block;\n" \
        "  white-space: pre;\n" \
        "  margin: 1em 0;\n" \
        "  font-family: courier;\n" \
        "}\n" \
        "\n" \
        "/* Display properties for hyperlinks */\n" \
        ":link    { color: darkblue; text-decoration: underline }\n" \
        ":visited { color: purple; text-decoration: underline }\n" \
        "\n" \
        "/* Deal with the \"nowrap\" HTML attribute on table cells. */\n" \
        "TD[nowrap] ,     TH[nowrap]     { white-space: nowrap; }\n" \
        "TD[nowrap=\"0\"] , TH[nowrap=\"0\"] { white-space: normal; }\n" \
        "\n" \
        "BR { \n" \
        "    display: block;\n" \
        "}\n" \
        "/* BR:before       { content: \"\\A\" } */\n" \
        "\n" \
        "/*\n" \
        " * Default decorations for form items. \n" \
        " */\n" \
        "INPUT[type=\"hidden\"] { display: none }\n" \
        "INPUT[type] { border: none }\n" \
        "\n" \
        "INPUT, INPUT[type=\"file\"], INPUT[type=\"text\"], INPUT[type=\"password\"], TEXTAREA { \n" \
        "  border: 2px solid;\n" \
        "  border-color: #848280 #ececec #ececec #848280;\n" \
        "}\n" \
        "\n" \
        "/*\n" \
        " * Default style for buttons created using <input> elements.\n" \
        " */\n" \
        "INPUT[type=\"submit\"] {\n" \
        "  display: inline-block;\n" \
        "  border: 2px solid;\n" \
        "  border-color: #ffffff #828282 #828282 #ffffff;\n" \
        "  background-color: #d9d9d9;\n" \
        "  color: #000000;\n" \
        "  padding: 3px 10px 1px 10px;\n" \
        "  white-space: nowrap;\n" \
        "  text-align: center;\n" \
        "}\n" \
        "INPUT[type=\"submit\"]:after {\n" \
        "  content: tcl(::tkhtml::attr value);\n" \
        "  position: relative;\n" \
        "}\n" \
        "INPUT[type=\"submit\"]:hover:active {\n" \
        "  border-color: #828282 #ffffff #ffffff #828282;\n" \
        "}\n" \
        "\n" \
        "INPUT[size] { width: tcl(::tkhtml::inputsize_to_css) }\n" \
        "\n" \
        "/* Handle \"cols\" and \"rows\" on a <textarea> element. By default, use\n" \
        " * a fixed width font in <textarea> elements.\n" \
        " */\n" \
        "TEXTAREA[cols] { width: tcl(::tkhtml::textarea_width) }\n" \
        "TEXTAREA[rows] { height: tcl(::tkhtml::textarea_height) }\n" \
        "TEXTAREA {\n" \
        "  font-family: fixed;\n" \
        "}\n" \
        "\n" \
        "FRAMESET {\n" \
        "  display: none;\n" \
        "}\n" \
        "\n" \
        "/*\n" \
        " *************************************************************************\n" \
        " * Below this point are stylesheet rules for mapping presentational \n" \
        " * attributes of Html to CSS property values. Strictly speaking, this \n" \
        " * shouldn't be specified here (in the UA stylesheet), but it doesn't matter\n" \
        " * in practice. See CSS 2.1 spec for more details.\n" \
        " */\n" \
        "\n" \
        "/* 'color' */\n" \
        "[color]              { color: tcl(::tkhtml::attr color -color) }\n" \
        "body a[href]:link    { color: tcl(::tkhtml::aa body link -color) }\n" \
        "body a[href]:visited { color: tcl(::tkhtml::aa body vlink -color) }\n" \
        "\n" \
        "/* 'width', 'height', 'background-color' and 'font-size' */\n" \
        "[width]            { width:            tcl(::tkhtml::attr width -len) }\n" \
        "[height]           { height:           tcl(::tkhtml::attr height -len) }\n" \
        "basefont[size]     { font-size:        tcl(::tkhtml::attr size) }\n" \
        "font[size]         { font-size:        tcl(::tkhtml::size_to_fontsize) }\n" \
        "[bgcolor]          { background-color: tcl(::tkhtml::attr bgcolor -color) }\n" \
        "\n" \
        "BR[clear]          { clear: tcl(::tkhtml::attr clear) }\n" \
        "BR[clear=\"all\"]    { clear: both; }\n" \
        "\n" \
        "/* Standard html <img> tags - replace the node with the image at url $src */\n" \
        "IMG[src]              { -tkhtml-replacement-image: tcl(::tkhtml::attr src) }\n" \
        "IMG                   { -tkhtml-replacement-image: \"\" }\n" \
        "\n" \
        "/*\n" \
        " * Properties of table cells (th, td):\n" \
        " *\n" \
        " *     'border-width'\n" \
        " *     'border-style'\n" \
        " *     'padding'\n" \
        " *     'border-spacing'\n" \
        " */\n" \
        "TABLE[border], TABLE[border] TD, TABLE[border] TH {\n" \
        "    border-top-width:     tcl(::tkhtml::aa table border -len);\n" \
        "    border-right-width:   tcl(::tkhtml::aa table border -len);\n" \
        "    border-bottom-width:  tcl(::tkhtml::aa table border -len);\n" \
        "    border-left-width:    tcl(::tkhtml::aa table border -len);\n" \
        "\n" \
        "    border-top-style:     tcl(::tkhtml::aa table border -if solid);\n" \
        "    border-right-style:   tcl(::tkhtml::aa table border -if solid);\n" \
        "    border-bottom-style:  tcl(::tkhtml::aa table border -if solid);\n" \
        "    border-left-style:    tcl(::tkhtml::aa table border -if solid);\n" \
        "}\n" \
        "TABLE[border=\"\"], TABLE[border=\"\"] td, TABLE[border=\"\"] th {\n" \
        "    border-top-width:     tcl(::tkhtml::aa table border -if 1px);\n" \
        "    border-right-width:   tcl(::tkhtml::aa table border -if 1px);\n" \
        "    border-bottom-width:  tcl(::tkhtml::aa table border -if 1px);\n" \
        "    border-left-width:    tcl(::tkhtml::aa table border -if 1px);\n" \
        "}\n" \
        "TABLE[cellpadding] td, TABLE[cellpadding] th {\n" \
        "    padding-top:    tcl(::tkhtml::aa table cellpadding -len);\n" \
        "    padding-right:  tcl(::tkhtml::aa table cellpadding -len);\n" \
        "    padding-bottom: tcl(::tkhtml::aa table cellpadding -len);\n" \
        "    padding-left:   tcl(::tkhtml::aa table cellpadding -len);\n" \
        "}\n" \
        "TABLE[cellspacing], table[cellspacing] {\n" \
        "    border-spacing: tcl(::tkhtml::attr cellspacing -len);\n" \
        "}\n" \
        "\n" \
        "/* Map the valign attribute to the 'vertical-align' property for table \n" \
        " * cells. The default value is \"middle\", or use the actual value of \n" \
        " * valign if it is defined.\n" \
        " */\n" \
        "TD,TH                        {vertical-align: middle}\n" \
        "TR[valign]>TD, TR[valign]>TH {vertical-align: tcl(::tkhtml::aa tr valign)}\n" \
        "TR>TD[valign], TR>TH[valign] {vertical-align: tcl(::tkhtml::attr  valign)}\n" \
        "\n" \
        "\n" \
        "/* Support the \"text\" attribute on the <body> tag */\n" \
        "body[text]       {color: tcl(::tkhtml::attr text -color)}\n" \
        "\n" \
        "/* Allow background images to be specified using the \"background\" attribute.\n" \
        " * According to HTML 4.01 this is only allowed for <body> elements, but\n" \
        " * many websites use it arbitrarily.\n" \
        " */\n" \
        "[background] {\n" \
        "    background-image: tcl(format \"url(%s)\" [::tkhtml::attr background])\n" \
        "}\n" \
        "\n" \
        "/* The vspace and hspace attributes map to margins for elements of type\n" \
        " * <IMG>, <OBJECT> and <APPLET> only. Note that this attribute is\n" \
        " * deprecated in HTML 4.01.\n" \
        " */\n" \
        "IMG[vspace], OBJECT[vspace], APPLET[vspace] {\n" \
        "    margin-top: tcl(::tkhtml::attr vspace -len);\n" \
        "    margin-bottom: tcl(::tkhtml::attr vspace -len);\n" \
        "}\n" \
        "IMG[hspace], OBJECT[hspace], APPLET[hspace] {\n" \
        "    margin-left: tcl(::tkhtml::attr hspace -len);\n" \
        "    margin-right: tcl(::tkhtml::attr hspace -len);\n" \
        "}\n" \
        "\n" \
        "/* marginheight and marginwidth attributes on <BODY> (netscape compatibility) */\n" \
        "BODY[marginheight] {\n" \
        "  margin-top: tcl(::tkhtml::attr marginheight -len);\n" \
        "  margin-bottom: tcl(::tkhtml::attr marginheight -len);\n" \
        "}\n" \
        "BODY[marginwidth] {\n" \
        "  margin-left: tcl(::tkhtml::attr marginwidth -len);\n" \
        "  margin-right: tcl(::tkhtml::attr marginwidth -len);\n" \
        "}\n" \
        "\n" \
        "SPAN[spancontent]:after {\n" \
        "  content: tcl(::tkhtml::attr spancontent);\n" \
        "}\n" \
        "\n" \
        "\n" \



#define HTML_DEFAULT_QUIRKS \
        "\n" \
        "/*------------------------------*/\n" \
        "/*      QUIRKS MODE RULES       */\n" \
        "/*------------------------------*/\n" \
        " \n" \
        "/* Tables are historically special. All font attributes except font-family,\n" \
        " * text-align, white-space and line-height) take their initial values.\n" \
        " */\n" \
        "TABLE {\n" \
        "  white-space:  normal;\n" \
        "  line-height:  normal;\n" \
        "  font-size:    medium;\n" \
        "  font-weight:  normal;\n" \
        "  font-style:   normal;\n" \
        "  font-variant: normal;\n" \
        "  text-align: left;\n" \
        "}\n" \
        "\n" \
        "/* Vertical margins of <p> elements do not collapse against the top or\n" \
        " * bottom of containing table cells.\n" \
        " */\n" \
        "TH > P:first-child, TD > P:first-child {\n" \
        "  margin-top: 0px;\n" \
        "}\n" \
        "TH > P:last-child, TD > P:last-child {\n" \
        "  margin-bottom: 0px;\n" \
        "}\n" \
        "\n" \
        "FORM {\n" \
        "  margin-bottom: 1em;\n" \
        "}\n" \
        "\n" \



#define HTML_SOURCE_FILES \
    "htmltable.c,v 1.105 2006/09/04 16:18:03 danielk1977 Exp\n" \
    "swproc.c,v 1.6 2006/06/10 12:38:38 danielk1977 Exp\n" \
    "htmlinline.c,v 1.30 2006/08/11 12:24:05 danielk1977 Exp\n" \
    "htmltree.c,v 1.89 2006/09/15 07:29:53 danielk1977 Exp\n" \
    "cssdynamic.c,v 1.8 2006/07/16 10:53:14 danielk1977 Exp\n" \
    "htmltagdb.c,v 1.10 2006/07/14 13:37:56 danielk1977 Exp\n" \
    "htmlhash.c,v 1.20 2006/08/28 08:42:35 danielk1977 Exp\n" \
    "htmlprop.c,v 1.93 2006/09/07 14:41:52 danielk1977 Exp\n" \
    "htmlparse.c,v 1.78 2006/08/24 14:53:02 danielk1977 Exp\n" \
    "htmltcl.c,v 1.125 2006/09/11 10:45:26 danielk1977 Exp\n" \
    "css.c,v 1.92 2006/08/28 08:42:34 danielk1977 Exp\n" \
    "htmllayout.c,v 1.216 2006/09/07 14:41:52 danielk1977 Exp\n" \
    "htmldecode.c,v 1.1 2006/07/01 07:33:22 danielk1977 Exp\n" \
    "main.c,v 1.8 2006/07/12 06:47:38 danielk1977 Exp\n" \
    "htmldraw.c,v 1.166 2006/09/07 11:03:02 danielk1977 Exp\n" \
    "htmlimage.c,v 1.56 2006/08/28 08:42:35 danielk1977 Exp\n" \
    "htmlfloat.c,v 1.19 2006/05/08 15:28:50 danielk1977 Exp\n" \
    "htmlstyle.c,v 1.46 2006/09/07 08:30:49 danielk1977 Exp\n" \
    "restrack.c,v 1.7 2006/06/28 06:31:11 danielk1977 Exp\n" \

