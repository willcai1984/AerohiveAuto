#!/usr/bin/perl
################################################################################
# File Name: get_time_hours_month_day_clock.pl
# Description: this script used to get the time in YYYY:MM:DD HH:MM
################################################################################
## Usage: perl get_time_hours_month_day.pl show_clock.log 2

use strict;
use warnings;
use Time::Local;

if(@ARGV != 2){
    print "ERROR: requires two argrments!\n";
    exit 0;
}

my $logfile = shift;
my $add_time = shift;
my $date_time;
my $current_time;
my $flags = 0;
my @array;
my $line;
my $mon_new;
my $date_new;

open(FILE, $logfile) || die "can't open the $logfile";
while($line = <FILE>){
	 if($line =~ /^\s+(\d+-\d+-\d+\s+\d+:\d+:\d+)/){
        $date_time = $1;
        last;
    }
	elsif(eof){
	print "error: Demand information is not exist";
	}
}

close FILE;
my ($date, $time) = split(/\s+/,$date_time);
my ($year, $mon, $day) = split(/-/, $date);
my ($hours, $min, $sec) = split(/:/, $time);
my $time_local = timelocal($sec, $min, $hours, $day, $mon-1, $year);

my $add_min = $time_local;
$add_min += $add_time;
my $local_time = scalar(localtime($add_min));
$local_time =~ /\s+(\w+\s+\d++\s+\d+:\d+:\d+\s+\d+)/;
print "$local_time" ;
