#!/usr/bin/perl
################################################################################
# File Name: Determine_fcc_wifi1_non_dfs_channel.pl
# Description: this script is used to check whether wifi1 channel dfs channel, 
#			   when the dfs channel wifi1 select, check the cost value of the wifi1 channel.
################################################################################
## Function: 
## Usage: perl Determine_fcc_wifi1_non_dfs_channel.pl debug.log wifi_channel.log wifi1

use strict;
use warnings;

if(@ARGV != 3) {
    print "requires three argrments!\n";
    exit 0;
}

my $debug_filename = shift;
my $channel_filename = shift;
my $wifi = shift;
my $line;
my $channel;
my $cost;
my $mini_cost;
my $i;
my $j;
my @check_value;
my @fcc_dfs_channel = ('52','56','60','64','100','104','108','112','116','132','136','140');
my @fcc_none_dfs_channel = ('36','40','44','48','149','153','157','161','165');

open(FILE , $debug_filename) || die "could not open $debug_filename";

while($line = <FILE>) {
    if($line =~ /$wifi.*?switch\s+to\s+chan\s*(\d+)./i){
        $channel = $1;
        last;
    }
    if(eof){
    print "error: not exsit $wifi at $debug_filename\n";
    exit 0 ;
    }
}

print "the channel : $channel\n";
close FILE;

for($i = 0; $i < @fcc_none_dfs_channel; $i ++) {
	if($channel == $fcc_none_dfs_channel[$i]){
		print "wifi1 selected non-dfs channel";
		exit 0;
	}
}

for($j = 0; $j < @fcc_dfs_channel; $j ++){
	if($channel == $fcc_dfs_channel[$j]){
		last;		
	}
	elsif($j == @fcc_dfs_channel - 1) {
		if($channel != $fcc_dfs_channel[$j]){
			print "error: the channel is error";
			exit 0;
		}
	}
}

open(FILENAME, $channel_filename) || die "could not open $channel_filename";
while($line = <FILENAME>){
    if($line =~ /^$wifi/i){
        last;
    }
}
if(eof){
    print "error: not exsit wifi1 at $channel_filename\n";
    exit 0;
}
while($line = <FILENAME>) {
    if($line =~ /lowest-cost:\s*([-\d]+)/i) {
        $cost = $1;
    }
    elsif($line =~ /Channel\s+$channel\s+Cost:([-\d]+)/i){
        $mini_cost = $1;
        last;
    }
    if(eof){
    print "error:there is not the channel info in log";
    exit 0 ;
    }
}

@check_value = ($cost,$mini_cost);
if(@check_value != 2){
	print "error:Did not get the two values";
	exit 0;
}

close FILENAME;

if($mini_cost == $cost){
   print "dfs channel cost is the lowest cost";
}
else{
	print "error:dfs channel cost not is the lowest cost";
	exit 0;
}