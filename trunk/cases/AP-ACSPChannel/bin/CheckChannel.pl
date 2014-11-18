#!/usr/bin/perl

## Function: 
## Usage: perl CheckChannel.pl channel.log 40U wifi_cost.log wifi0

use strict;
use warnings;

if(@ARGV != 4){
    print "requires four argrments!\n";
    exit 0;
}

my $filename = $ARGV[0];
my $pattern = $ARGV[1];
my $checked_filename = $ARGV[2];
my $wifi_n = $ARGV[3];
my $line;
my @array;
my $channel_n;
my @temp;

open(FILE, $filename) || die "could not open $filename";
while($line = <FILE>){
    @temp = split(/(?=Channel)/, $line);
    for(@temp){
        if($_ =~ /Channel\s+(\d+)(.*?$pattern)/ig){
            push @array, $1; 
        } 
    }
}
close FILE;

open(FILEHANDLE, $checked_filename) || die "could not open $checked_filename";
while($line = <FILEHANDLE>){
    if($line =~ /^$wifi_n/){
        last;
    }
}
if(eof){
    print "error: not exsit $wifi_n at $checked_filename\n";
    exit 0;
}
while($line = <FILEHANDLE>){
    if($line =~ /Channel\s+(\d+)\s+Cost/i){
        if(@array > 0){
            $channel_n = shift @array;
        }
        if($1 != $channel_n){
            print "FAIL\n";
            exit 0;
        }
        $channel_n = 0;
    }elsif( ($line =~ /^$/) || ($line =~ /^wifi/i) ){
        last;
    }
}

if(@array > 0){
print "FAIL\n";
    exit 0;
}
print "SUCCESS\n";
close FILEHANDLE;
