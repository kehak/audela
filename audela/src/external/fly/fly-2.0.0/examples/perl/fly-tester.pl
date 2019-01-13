#!/usr/local/web/bin/perl
### ---------------------------------------------------------------------- ###
#
# Fly tester
#
# *Requires* perl 5.001 or greater and the CGI module.
#
# (c) Copyright 1998, Martin Gleeson <gleeson@unimelb.edu.au>
#       <URL:http://www.unimelb.edu.au/%7Egleeson/>
#
# You may use and/or modify this script freely, but not redistribute it
# without my permission.
#
# Version 1.1, 11 June 1999
#
# - added mode to show diagnostic output
# - disallowed 'copy' and 'copyresized' due to security risk.
#
# Version 1.0, 25 September 1998
#
use strict;
### ---------------------------------------------------------------------- ###
#   User configurable settings
### ---------------------------------------------------------------------- ###

# Where the temporary images will be stored
my $output_area = "/home/usr/its/gleeson/public_html/fly/graphs";

# URL path to same
my $graphs_url = "/%7Egleeson/fly/graphs";

# location of the fly program
my $flyprog = "/home/usr/its/gleeson/bin/fly";

### ---------------------------------------------------------------------- ###
#   End of configurable settings - no editing required below this line.
### ---------------------------------------------------------------------- ###

use CGI;
my $q = new CGI;

my ($testcode, $version, $helpscreen, $diags);

&my_setup();

if($q->path_info =~ /quickref/) {
	print $q->header(),
		$q->start_html(-title=>'Fly Tester: Fly Quick Reference', -bgcolor=>"#FFFFFF"),
		$q->h1('Fly Quick Reference'),
		$q->hr(),
		$q->pre($helpscreen),
		$q->hr(),
		$q->end_html();
} elsif($q->request_method() eq "GET") {
	my $cw = 40;
	my $ch = 30;
	my $cell = $q->startform("POST",$q->url(),$CGI::URL_ENCODED) .
		$q->textarea(-rows=>$ch, -columns=>$cw, -name=>"code", -default=>$testcode) .
		$q->br() .
		$q->div({-align=>"right"},
			"Command window width: ",
			$q->textfield(-name=>'cw', -default=>$cw, -size=>2, -maxlength=>3),
			" height: ",
			$q->textfield(-name=>'ch', -default=>$ch, -size=>3, -maxlength=>4),
			$q->br,
			"Show diagnostic output? ",
			$q->checkbox(-name=>'do',-label=>''),
			$q->br,
			$q->submit(-name=>'Submit', -value=>'Generate Image'));

	print $q->header(),
		$q->start_html(-title=>'Fly Tester',
			-bgcolor=>"#FFFFFF"),
		$q->h1('Fly Test Page'),
		$q->hr(),
		$q->p("Here you can test ", $q->a({-href=>"http://www.unimelb.edu.au/fly/"},"fly"),
			" commands and see the results instantly."),
		$q->table({-border=>"0"},$q->Tr($q->td($cell))),
		$q->hr(),
		$q->p({-align=>"center"}, "<small>This is part of the ",
			$q->a({-href=>"http://www.unimelb.edu.au/fly/"},"fly"), " package.</small>"),
		$q->hr(),
		$q->endform(),
		$q->end_html();

} elsif($q->request_method() eq "POST") {
	my $code = $q->param('code');
	$diags = $q->param('do');
	my ($cell1, $cell2);
	
	print $q->header(),
		$q->start_html(-title=>'Fly Tester',
			-bgcolor=>"#FFFFFF"),
		$q->h1('Fly Test Page'),
		$q->hr();

	my $inputfile = "/tmp/fly.$$.input";
	my $outputfile = "/tmp/fly.$$.output";
	$code =~ s/
//g;
	if($code =~ /^copy/m) {
		print $q->h2("Error"),
		$q->p("The copy and copyresized commands cannot be used from within this program.</p>"),
		$q->hr(),
		$q->p({-align=>"center"}, "<small>This is part of the ",
			$q->a({-href=>"http://www.unimelb.edu.au/fly/"},"fly"), " package.</small>"),
		$q->hr(),
		$q->end_html();
		exit 0;
	}
	open INPUT, ">$inputfile" or die "Couldn't open $inputfile for writing: $!\n"; print INPUT $code; close INPUT;
	my $return_code = system("$flyprog -i $inputfile -o $output_area/fly.$$.gif > $outputfile 2>&1");
	if($return_code == 0) {
		$cell1 =  $q->p({-align=>'center'}, $q->img({-src=>"${graphs_url}/fly.$$.gif",
			-alt=>"[Generated Graph]", -border=>"2"}));
		my $url = $q->url();
		if($diags) {
			open OUTPUT, "$outputfile" or die "Couldn't open $outputfile for reading: $!\n";
			my @lines = <OUTPUT>; my $text = join('',@lines); close OUTPUT;
			$cell1 .=  $q->table($q->Tr($q->td($q->pre($text))));
		}
		$cell1 .=  $q->p({-align=>"center"}, "<small><b>fly</b> version $version.</small>", $q->br(),
			$q->a({-href=>"$url/quickref"},"<small>Quick Reference.</small>")),
	} else {
		open ERR, $outputfile or die "Couln't open $outputfile for reading: $!"; my $output = join '', <ERR>; close ERR;
		$cell1 = $q->p("Error producing image: <b>$output</b>"),
	}
	unlink $inputfile;
	unlink $outputfile;
	$cell2 = $q->startform("POST",$q->url(),$CGI::URL_ENCODED) .
		$q->textarea(-rows=>$q->param('ch'), -columns=>$q->param('cw'), -name=>"code", -default=>$q->param('code')) .
		$q->br() . 
		$q->div({-align=>"right"},
			"Command window width: ",
			$q->textfield(-name=>'cw', -default=>$q->param('cw'), -size=>2, -maxlength=>3),
			" height: ",
			$q->textfield(-name=>'ch', -default=>$q->param('ch'), -size=>3, -maxlength=>4),
			$q->br,
			"Show diagnostic output? ",
			$q->checkbox(-name=>'do',-label=>''),
			$q->br,
			$q->submit(-name=>'Submit', -value=>'Generate Image')) .
		$q->endform();

	print $q->table({-border=>"0", -width=>"100%"},$q->Tr($q->td({-valign=>"top"},$cell2),
		$q->td({-valign=>"top", -valign=>"top", -align=>'center'},$cell1))),
		$q->hr(),
		$q->p({-align=>"center"}, "<small>This is part of the ",
			$q->a({-href=>"http://www.unimelb.edu.au/fly/"},"fly"), " package.</small>"),
		$q->hr(),
		$q->end_html();
}
exit 0;

sub my_setup {
	$testcode = <<EOF;
# sample fly commands
# this is the smiley face example 

# new image
new
size 256,256

# fill with white
fill 1,1,255,255,255

# create a circle
circle 128,128,180,0,0,0

# fill it with yellow
fill 128,128,255,255,0

# create a smile
arc 128,128,120,120,0,180,0,0,0

# or even a frown
# arc 128,188,90,120,180,0,0,0,0

# create the eyes
circle 96,96,10,0,0,0
circle 160,96,10,0,0,0
fill 96,96,0,0,0
fill 160,96,0,0,0
EOF

	open FLY, "$flyprog -v |" or die "Couldn't run $flyprog -v: $!\n";
	while(<FLY>) {
		if (/version/) {
			($version) =  /([\d\.]+)/;
		}
		next if/directives/i or /documentation/i or /version/i;
		s/&/&amp;/g;
		s/</&lt;/g;
		s/>/&gt;/g;
		$helpscreen .= $_;
	}
	$helpscreen =~ s/\n\n\n/\n/;
	close FLY;
}

