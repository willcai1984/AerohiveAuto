#!/usr/bin/perl
################################################################################
# File Name: Judge_min_value_cost.pl
# Autor: Fang Ye
# Description: this script is use to check wether the input channle has the mini cost
################################################################################

## Function:
## Usage: perl Judge_min_value_cost.pl channel.log 40

use strict;
use warnings;
use Statistics::Descriptive::Discrete;
my $FAIL=1;
my $PASS=0;

my @array = "";
my $valuescan_first = 0;
if ( @ARGV != 2 ) {
        print "requires four argrments!\nFAIL\n";
        exit 1;
}

my $filename = $ARGV[0];
my $compare_channel   = $ARGV[1];
my $compare_channel_cost = 0;
my $stats = new Statistics::Descriptive::Discrete;
my $min;
sub get_channle_input {
        my $line;
        my @temp = "";
        open( FILE, $filename ) || die "could not open $filename";
        while ( $line = <FILE> ) {
                @temp = split( /(\n)/, $line );
                for (@temp) {
                        if ( $_ =~ /Channel\s+$compare_channel\s+Cost:([\-0-9]+)/ ) {
                                $compare_channel_cost = $1;
                        }
                        if ($_ =~ /Channel\s+\d+\s+Cost:([\-0-9]+)/ ) {
                                 $stats->add_data($1);
                        }
                }
        }
        close FILE;
        return $PASS;
}

if (get_channle_input() != $PASS) {
        print "FAIL\n";
        exit 1;
}
$min = $stats->min();
if ($compare_channel_cost != $min ) {
        print "the min cost is $min the cost of input channle is $compare_channel_cost FAIL\n";
        exit 1;
}

print "SUCCESS\n";
exit 0;
