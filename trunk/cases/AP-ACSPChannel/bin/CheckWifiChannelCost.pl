#!/usr/bin/perl

## Function: 
## Usage: perl CheckWifiChannelCost.pl wifi_cost.log wifi0

use strict;
use warnings;

if(@ARGV != 2){
    print "requires two argrments!\n";
    exit 0;
}
my $logfile = shift;
my $wifi_n = shift;
my $line;
my $lowest_cost_channel = 0;
my $lowest_cost_channel_cost;
my $lowest_cost;
my @cost;
my $min_cost;

open(FILE, $logfile) || die "could not open $logfile";
while($line = <FILE>){
    if($line =~ /^$wifi_n/){
        last;
    }
}
if(eof){
    print "error: not exsit $wifi_n at $logfile\n";
    return 1;
}
while($line = <FILE>){
    if($line =~ /Lowest\s+cost\s+channel:\s+(\d+),\s+lowest-cost:\s+(-?\d+)/i){
        $lowest_cost_channel = $1;
        $lowest_cost = $2;
    }elsif($line =~ /Channel\s+$lowest_cost_channel\s+Cost:(-?\d+)/i){
        $lowest_cost_channel_cost = $1;
        push @cost, $1;
    }elsif($line =~ /Channel\s+\d+\s+Cost:(-?\d+)/i){
        push @cost, $1;
    }elsif($line =~ /^wifi/i){
        last;
    }
}

close FILE;

if(@cost == 1){
    $min_cost = $cost[0];
}
if(@cost > 1){
    $min_cost = $cost[0];
    my $i = 1;
    while($i <= $#cost){
       if($cost[$i] < $min_cost){
           $min_cost = $cost[$i];
       }
       $i = $i + 1;
    }
}

#print "min cost is $min_cost\n";    

if($lowest_cost == $min_cost && $lowest_cost_channel_cost == $lowest_cost){
    print "SUCCESS\n";
}else{
    print "FAIL\n";
}
