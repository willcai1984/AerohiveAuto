#!/usr/bin/perl

## Function:
## Usage: perl Check_CCA_adjustment.pl step5_show_cca_buffer.log

use strict;
use warnings;

if(@ARGV != 1){
    print "requires 1 argrments!\n";
    exit 0;
}

my $filename =  shift;
my $default_cca=33;
my $max_cca=55;
my $line;

open(FILE, $filename) || die "could not open $filename";
while($line = <FILE>){
    if($line =~/adj\s+cca\s+from\s+\d+\s+to\s+(\d+)\s+interference\s+(\d+)/i){
        if($2 < 5){
            if($1 != $default_cca){
                print "error:CCA Threshold is error";
                exit 0;
            }
            else {
                last;
            }
        }
        if($2 >= 5 && $2 < 10){
            if($1 != $default_cca + 3){
                print "error:CCA Threshold is error";
                exit 0;
            }
            else {
                last;
            }
        }
        if($2 >= 10 && $2 < 15){
            if($1 != $default_cca + 6){
                print "error:CCA Threshold is error";
                exit 0;
            }
            else {
                last;
            }
        }
        if($2 >= 15 && $2 < 20){
            if($1 != $default_cca + 9){
                print "error:CCA Threshold is error";
                exit 0;
            }
            else {
                last;
            }
        }
        if($2 >= 20 && $2 < 25){
            if($1 != $default_cca + 12){
                print "error:CCA Threshold is error";
                exit 0;
            }
            else {
                last;
            }
        }
        if($2 >= 25){
            if($1 != $max_cca){
                print "error:CCA Threshold is error";
                exit 0;
            }
            else {
                last;
            }
        }
    }
}

if(eof){
    print "error: not exist log information at $filename\n";
    exit 0;
}
print "SUCCESS\n";
close FILE;
