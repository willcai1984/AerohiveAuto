#!/usr/bin/perl

## this script function is getting channel from log 

use strict;
use warnings;

if(@ARGV != 1){
    print "only requires one argrments!\n";
    exit 0;
}

my $filename = shift;
my $line;
my @array;

open(FILE, $filename) || die "could not open $filename";
while($line = <FILE>){
   while($line =~ /Default\s+Gateway:(\d+).*?(\d+).*?(\d+).*?(\d+).*?/ig){
      push @array, $1;
 push @array, $2;
  push @array, $3;
   push @array, $4;
   } 
}

print join(".", @array);
close FILE;
