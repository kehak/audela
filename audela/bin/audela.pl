#!/usr/bin/perl
#------ Benjamin Mauclaire 2004 for AudeLA's team ---------#
use strict;


sub exec_audela
{
  my $chemin =~ s/audela.tcl//g;
  print `typeset -x LD_LIBRARY_PATH=$chemin`;
  print `cd $chemin`;
  #print `./audela`;
  exec ("./audela");
}


my $lieu = `pwd`;

#print `locate binlinux | grep audela.tcl`;
# Il faut recuperer le resulata de la commande dans un tableau
#pour proposer un choix de PATH a l'utilisateur

my @locate = `locate bin | grep audela.tcl`;

foreach my $line (@locate)
{
	chomp $line;
    print "$line est-elle la version que vous souhaitez (o/n) ? : ";
    my $rep=<STDIN>;
    chop $rep;
    #print "$rep\n";
    if ($rep=~ /o/)
    {
	#chomp $line;
	$line =~ s/\/audela.tcl/\//g;
	# Tous dans la meme ligne, sinon variable oubliee car shells differents
	exec ("typeset -x LD_LIBRARY_PATH=$line; cd $line;./audela & cd $lieu");
    }
}




