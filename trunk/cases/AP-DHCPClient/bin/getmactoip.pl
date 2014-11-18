#!/usr/bin/perl

## Function: 
## Usage: perl collect_mac.pl show_interface.log mgt0

use strict;
use warnings;

if(@ARGV != 2) {
    print "requires two argrments!\n";
    exit 0;
}

my $interface_filename = shift;
my $interface_name = shift;
my $f_num;
my $s_num;
my $line;

open(FILE , $interface_filename) || die "could not open $interface_filename";

while($line = <FILE>) {
    if($line =~ /^$interface_name\s+.*:\w+:(\w{2})(\w{2})/i){
        $f_num = hex($1);
        $s_num = hex($2);
        last;
    }
    if(eof){
        print "error: not exsit $interface_name\n";
        exit 0 ;
    }
}
close FILE;
my $a = "192.168.$f_num.$s_num";
print $a;