#!/usr/bin/perl

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

open(FILE, $logfile) || die "can't open the $logfile";
while($line = <FILE>){
    if($line =~ /(\d+-\d+-\d+\s+(\d+:\d+):\d+)/){
        $date_time = $1;
        $current_time = $2;
        $flags = 1;
        last;
    }
}
close FILE;
if($flags == 0){
    print "ERROR: not exist time at $logfile";
    exit 0;
}
my ($date, $time) = split(/\s+/,$date_time);
my ($year, $mon, $day) = split(/-/, $date);
my ($hours, $min, $sec) = split(/:/, $time);
my $time_local = timelocal($sec, $min, $hours, $day, $mon-1, $year);

my $add_min = $time_local;
$add_min += $add_time * 60;
my $local_time = scalar(localtime($add_min));
$local_time =~ /(\d+:\d+)/;
push @array, "$year-$mon-$day $1";

print "@array";
