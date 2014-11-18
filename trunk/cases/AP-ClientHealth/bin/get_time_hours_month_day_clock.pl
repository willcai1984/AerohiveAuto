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
	if($line =~ /^(\d+-\d+-\d+\s+(\d+:\d+):\d+)\s+debug\s+\[fe\]:\s+parse\s+DHCP\s+pkt/i){
		$date_time = $1;
        $current_time = $2;
        $flags = 1;
        last;
	}
	elsif($line =~ /^\s+(\d+-\d+-\d+\s+(\d+:\d+):\d+)/){
        $date_time = $1;
        $current_time = $2;
        $flags = 1;
        last;
    }
}
if(eof){
	print "error: Demand information is not exist"
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
$local_time =~ /\s+(\w+)\s+(\d+)+\s+(\d+:\d+):\d+\s+(\d+)/;

if($1 eq "Dec"){
	$mon_new = 12;
}
if($1 eq "Nov"){
	$mon_new = 11;
}
if($1 eq "Oct"){
	$mon_new = 10;
}
if($1 eq "Sep"){
	$mon_new = "09";
}
if($1 eq "Aug"){
	$mon_new = "08";
}
if($1 eq "Jul"){
	$mon_new = "07";
}
if($1 eq "Jun"){
	$mon_new = "06";
}
if($1 eq "May"){
	$mon_new = "05";
}
if($1 eq "Apr"){
	$mon_new = "04";
}
if($1 eq "Mar"){
	$mon_new = "03";
}
if($1 eq "Feb"){
	$mon_new = "02";
}
if($1 eq "Jan"){
	$mon_new = "01";
}

if($2 < 10){
	$date_new = "0$2";
}
else{
	$date_new = "$2";
}

push @array, "$4-$mon_new-$date_new $3";

print "@array";
