#!/usr/bin/perl
################################################################################
# File Name: check_scan-channel.pl
# Autor: Fang Ye
# Description: this script is use to check the subnet status
################################################################################

## Function:
## Usage: perl check_scan-channel.pl channel.log 40U dfswifi1140

use strict;
use warnings;
my $FAIL=1;
my $PASS=0;
my @channel1 = ( 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 );
my @channel2 = ( 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 );
my @channel3 = (36,  40,  44,  48,  52,  56,  60,  64,  100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140);
my @channel4 = (36,  40,  44,  48,  52,  56,  60,  64,  100, 104, 108, 112,116, 132, 136, 140, 149, 153, 157, 161, 165);
my @channel5 = (36, 40, 44, 48, 149, 153, 157, 161, 165 );
my @channel6 = (52, 56, 60, 64, 100, 104, 108, 112, 116, 132, 136, 140 );
my @channel7 = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 36, 40, 44, 48, 149, 153, 157, 161, 165 );

my @array = "";
my @checkarray = "";
my @tmparray;
my $valuescan_first = 0;
if ( @ARGV != 2 ) {
	print "requires four argrments!\nFAIL\n";
	exit 1;	
}

my $filename = $ARGV[0];
my $wifi_n   = $ARGV[1];

sub get_channel_tmp {
	for ($wifi_n) {
		/840wifi0/i && do {
			@checkarray = @channel1;
			last;
		};
		/826wifi0/i && do {
			@checkarray = @channel2;
			last;
		};
		/dfswifi140/i && do {
			@checkarray = @channel3;
			last;
		};
		/dfswifi165/i && do {
			@checkarray = @channel4;
		};
		/nodfswifi165/i && do {
			@checkarray = @channel5;
		};	
		/dfswifi52/i && do {
			@checkarray = @channel6;
		};	
		/brfcc/i && do {
			@checkarray = @channel7;
		};		
	}
}

sub get_channle_input {
	my $line;
	my @temp = "";
	open( FILE, $filename ) || die "could not open $filename";
	while ( $line = <FILE> ) {
		@temp = split( /(\n)/, $line );
		for (@temp) {
			if ( $_ =~ /next foreign channel\s+(\d+),/ ) {
				push @array, $1;
			}
			elsif ($_ =~ /entering channel=(\d+)/ ) {
				push @array, $1;
			}
			elsif($_ =~ /wlc_scan: scan channels\s+(\d+)/) {
				push @array, $1;
			}
		}
	}
	close FILE;
	return $PASS;
}


#check wehter the value has opperance twice
sub check_channel_first {
	my $value1 = 0;
	my $value2 = 0;
	my $flag = 0;
	foreach $value1 (@array) {
		$flag = 0;
		foreach $value2 (@array) {
			if ( $value1 eq $value2 ) {
				$flag++;
			}
			if ( $flag == 2 ) {
				print "the channel we find occure twice first id $valuescan_first";
				$valuescan_first = $value1;
				return $PASS;
			}
		}

	}
	if ( $flag != 2 ) {
		return $FAIL
	}
	return $PASS;
}

sub copy_scan_channel_list {
	my $flag = 0;
	my $value1 = 0;
	my $value2 = 0;	
	 my $current = 0;
	 my $tmp;
	for(; $current <= $#array; $current++) {
		$tmp = shift @array;
		if ( $tmp eq  $valuescan_first ) {
			$flag++;
		}
		if ( $flag == 1 ) {
			push @tmparray, $tmp;
		}
		if ( $flag == 2 ) {
			last;
		}
	}
	return $PASS;
}

sub check_value {
	my $value1 = 0;
	my $value2 = 0;	
	my $flag =0;
	foreach $value1 (@tmparray) {
		print "the channel $value1 should be found";
		$flag = 0;
		foreach $value2 (@checkarray) {
			if ( $value1 == $value2 ) {
				print "the channle $value1 is found!\n";
				$flag = 1 ;				
			}	
		}
		if ($flag != 1) {
			print "the channle $value1 not found!!!!!\n";
			return $FAIL;
		}	
	}
	return $PASS;
}



get_channel_tmp();
if (get_channle_input() != $PASS) {
        print "FAIL\n";
        exit 1;
}
if (check_channel_first() != $PASS) {
        print "FAIL\n";
        exit 1;
}
copy_scan_channel_list();
if (check_value() != $PASS) {
        print "FAIL\n";
        exit 1;
}
print "SUCCESS\n";
exit 0;
