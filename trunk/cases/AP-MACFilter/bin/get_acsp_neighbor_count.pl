#!/usr/bin/perl

## this script function is getting the number of wifi1's acsp neighbor from wifi1's acsp neighbor list

use strict;
use warnings;

if(@ARGV != 1){
    print "only requires one argrments!\n";
    exit 0;
}

my $filename = shift;
my $line;
my $count=0;

open(FILE, $filename) || die "could not open $filename";

while($line = <FILE>){
    if($line =~ /^wifi1.*\s+ACSP\s+neighbor\s+list:/){
        last;
    }
}
while($line = <FILE>){
	while($line =~ /(\w+):(\w+):(\w+)/ig){
     $count=$count+1;
}
}

print $count;
close FILE;
