#!/usr/bin/perl

## Function: 
## Usage: perl CompareChannel.pl channel1.log channel2.log wifi0

use strict;
use warnings;

if(@ARGV != 3){
    print "requires three argrments!\n";
    exit 0;
}

my $filename_org = shift;
my $filename_checked = shift;
my $interface_name = shift;
my $line;
my $channel_org;
my $channel_checked;
my @arraya;
my @arrayb;
my @arrayc;

open(FILE, $filename_org) || die "could not open $filename_org";
while($line = <FILE>){
    while($line =~ /Channel\s+(\d+)\s+:/ig){
        push @arraya, $1;
    }
}
close FILE;

open(FILECHECKED, $filename_checked) || die "could not open $filename_checked";
while($line = <FILECHECKED>){
    if($line =~ /$interface_name.*?channel\((\d+)\)/i){
        push @arrayb, $1;
    }
}
close FILECHECKED;

my $array_len = @arrayb - 1;
while($array_len >= 0){
    push @arrayc, $arrayb[$array_len];
	$array_len = $array_len - 1;
}

while(@arraya > 0){
    $channel_org = shift @arraya;
    $channel_checked = 0;
    if(@arrayc > 0){
        $channel_checked = shift @arrayc;
    }
    if($channel_checked != $channel_org){
        print "error: channel is not same!";
        exit 0;
    }
}
if(@arrayc > 0){
    print "FAIL\n";
    exit 0;
}
print "SUCCESS";