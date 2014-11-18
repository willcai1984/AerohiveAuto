#!/usr/bin/perl
################################################################################
# File Name: get_rx_airtime.pl
# Description: this script used to get the rx airtime parameters
################################################################################
## Usage: perl get_rx_airtime.pl show_buffer.log

use strict;
use warnings;

if(@ARGV != 1) {
    print "requires three argrments!\n";
    exit 0;
}

my $file_name = shift;
my $list;
my $rx_airtime;

open(FILE, $file_name) || die "could not open $file_name";

while($list = <FILE>){
    if($list =~/^([\d.]+)s\s+rx\s+airtime$/i){
        $rx_airtime = $1 * 1000;
        last;
    }
    elsif($list =~/^([\d.]+)ms\s+rx\s+airtime$/i){
        $rx_airtime = $1;
        last;
    }
}
if(eof){
    print "ERROR: not exist rx airtime";
    exit 0;
}
print "$rx_airtime";