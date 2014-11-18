#!/usr/bin/perl

## Function:
## Usage: perl get_tx_airtime.pl show_buffer.log

use strict;
use warnings;

if(@ARGV != 1) {
    print "requires three argrments!\n";
    exit 0;
}

my $file_name = shift;
my $list;
my $tx_airtime;

open(FILE, $file_name) || die "could not open $file_name";

while($list = <FILE>){
    if($list =~/^([\d.]+)s\s+tx\s+airtime$/i){
        $tx_airtime = $1 * 1000;
        last;
    }
    elsif($list =~/^([\d.]+)ms\s+tx\s+airtime$/i){
        $tx_airtime = $1;
        last;
    }
}
if(eof){
    print "ERROR: not exist tx airtime";
    exit 0;
}
print "$tx_airtime";