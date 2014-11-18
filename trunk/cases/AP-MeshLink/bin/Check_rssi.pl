#!/usr/bin/perl
################################################################################
# File Name: Check_rssi.pl
# Description: this script used to check the largest avg rssi of channel and mac
################################################################################
## Usage: perl Check_rssi.pl show_debug_rssi.log -c

use strict;
use warnings;

if(@ARGV != 2){
    print "ERROR: requires two argrments!\n";
    exit 0;
}

my $file_debug = shift; 
my $parameter = shift;
my $line;
my $max_rssi;
my $mac_addr;
my $channel;
my @array1;

open(FILE, $file_debug) || die "could not open $file_debug";
while($line = <FILE>){
	if($line =~ /acsp\s+mesh\s+path.*?avg\s+rssi\((\d+)\)/i){
		push @array1, $1;
	}
}
close FILE;

if(@array1 == 0){
	print "ERROR: do not get the value of rssi.";
	exit 0;
}

if(@array1 == 1){
	$max_rssi = $array1[0];
}

if(@array1 > 1){
	$max_rssi = $array1[0];
	my $i = 1;
	while($i <= $#array1){
		if($array1[$i] > $max_rssi){
			$max_rssi = $array1[$i];
		}
		$i = $i + 1;
	}
}


open(FILE, $file_debug) || die "could not open $file_debug";
while($line = <FILE>){
	if($line =~ /acsp\s+mesh\s+path\(mac:\s+([\d\w]+:[\d\w]+:[\d\w]+),\s+chan:\s+(\d+)\):.*?avg\s+rssi\($max_rssi\)/i){
		$mac_addr = $1;
		$channel = $2;
		last;
	}
}
if(eof){
	print "ERROR: not exist the value of rssi";
	exit 0;
}
close FILE;

if($parameter eq "-c"){
	print "$channel";
}

if($parameter eq "-m"){
	print "$mac_addr";
}

if ($parameter ne "-c" && $parameter ne "-m"){
	print "ERROR: the $parameter is a incorrect parameter ";
	exit 0;
}

