#!/usr/bin/perl

## Usage: perl get_access_counter.pl data-collection.log buffer.log from-access|to-access time(min)
use strict;
use warnings;
use Time::Local;

if(@ARGV != 4){
    print "ERROR: requires two argrments!\n";
    exit 0;
}

my $data_collect = shift;
my $log_buffer = shift;
my $access_type = shift;
my $interval_time = shift;
my $year;
my $mon;
my $day;
my $time_value;
my $flag;
my $line;
my $access_sum = 0;

open(FILE, $data_collect) || die "can't open the $data_collect";
while($line = <FILE>) {
    if ($line =~ /FE\s+timestamp:\w+\s+(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+(\d+)/) {
        if($1 eq "Dec"){
            $mon = 12;
        }
        if($1 eq "Nov"){
            $mon = 11;
        }
        if($1 eq "Oct"){
            $mon = 10;
        }
        if($1 eq "Sep"){
            $mon = "09";
        }
        if($1 eq "Aug"){
            $mon = "08";
        }
        if($1 eq "Jul"){
            $mon = "07";
        }
        if($1 eq "Jun"){
            $mon = "06";
        }
        if($1 eq "May"){
            $mon = "05";
        }
        if($1 eq "Apr"){
            $mon = "04";
        }
        if($1 eq "Mar"){
            $mon = "03";
        }
        if($1 eq "Feb"){
            $mon = "02";
        }
        if($1 eq "Jan"){
            $mon = "01";
        }
        $day = $2;
        $time_value = $3;
        $year = $4;
        $flag = 1;
        last;
    }
}
close FILE;
if ($flag != 1) {
    print "ERROR: not exist time at $data_collect";
    exit 0;
}

my($hour_time, $min_time, $sec_time) = split(/:/, $time_value);
my $time_local = timelocal($sec_time, $min_time, $hour_time, $day, $mon-1, $year);
my $end_time = $time_local;
my $value = $interval_time * 60;
my $start_time = $end_time - $value;

open(FILE_log, $log_buffer) || die "can't open the $log_buffer";
while ($line = <FILE_log>) {
    if ($line =~ /^(\d+-\d+-\d+)\s+(\d+:\d+:\d+)\s+debug\s+kernel:\s+\[fe\]:\s+update\s+$access_type\s+counters\s+(\d+)\s+bytes$/i) {
        my($year, $month, $day) = split(/-/, $1);
        my($hour, $min, $sec) = split(/:/, $2);
        my $time_local = timelocal($sec, $min, $hour, $day, $month-1, $year);
        if ($time_local >= $start_time && $time_local <= $end_time) {
            $access_sum += $3;
        }
    }
}
close FILE_log;
print "$access_sum";