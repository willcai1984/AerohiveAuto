#!/usr/bin/perl

## get oui from mac

use strict;
use warnings;

if(@ARGV != 1){
    print "only requires one argrments!\n";
    exit 0;
}

my $mac_address = shift;
my @oui;
while($mac_address =~ /(\w\w)(\w\w):(\w\w).*/ig){
      push @oui,$1;
	  push @oui,$2;
	  push @oui,$3;
   } 

print join(":", @oui);

