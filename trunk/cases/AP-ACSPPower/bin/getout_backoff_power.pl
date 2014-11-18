#!/usr/bin/perl
#get backoff power of wifix(such as wifi1,wifi0)

use strict;
use warnings;
my $filename=shift;
my $wifi_x=shift;
my $line;
open(F,$filename) || die "failed to open $filename";
while($line = <F>){
	if($line =~ /interface$wifi_x.*backoff\s+is\s+(\d+)/i){
	    print $1;
	}
}
close(F);

