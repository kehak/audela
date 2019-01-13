#!/usr/local/bin/perl
#
#  Simple script using fly to find the dimensions of an image.
#
#  Martin Gleeson, January 1996
#

if( ! $ARGV[0] ) {
	print STDERR "Usage: size <GIF image>\n";
	exit(0);
}
foreach $arg (@ARGV) {
	open(FLY,"> /tmp/fly.$$");
	print FLY "existing $arg\n";
	print FLY "sizex\n";
	print FLY "sizey\n";
	close(FLY);

	open(OUT, "fly -i /tmp/fly.$$ -o /dev/null |");
	while(<OUT>) {
		($x) = /is\ (\d+)$/ if /Size\ -\ X/;
		($y) = /is\ (\d+)$/ if /Size\ -\ Y/;
	}
	close(OUT);

	print "Dimensions of $arg: $x by $y\n";
	undef($x);undef($y);
}
