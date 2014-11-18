#!usr/bin/perl

## Usage: perl Clock_compare.pl Show_clock.log mc_clock.log start_error end_error
use strict;
use warnings;
use Time::Local;

if(@ARGV != 4){
    print "ERROR: requires four argrments!\n";
    exit 0;
}

my $show_clock = shift;
my $clock = shift;
my $start_error = shift;
my $end_error = shift;
my %monthash = ("Jan"=>"01","Feb"=>"02","Mar"=>"03","Apr"=>"04","May"=>"05","Jun"=>"06","Jul"=>"07","Aug"=>"08","Sep"=>"09","Oct"=>"10","Nov"=>"11","Dec"=>"12");
my $line;
my $date;
my $time;
my $mon_clock;
my $day_clock;
my $year_clock;

open(FILE, $show_clock) || die "can't open the $show_clock";
open(FILE_Clock, $clock) || die "can't open the $clock";

while($line = <FILE>) {
    if ($line =~ /(\d+\-\d+\-\d+)\s+(\d+:\d+:\d+)\s+\w+/) {
        $date = $1;
        print "date: $date\n";
        $time = $2;
        print "time: $time\n";
        last;
    }
    if(eof) {
        print "Error:no time matched in $show_clock\n";
        exit 0;
    }
}
my ($year,$mon,$day) = split('-',$date);
my ($hour,$min,$sec) = split(':',$time);
my $time_local = timelocal($sec,$min,$hour,$day,$mon-1,$year-1900);
print "show AP time: $time_local\n";

while($line = <FILE_Clock>) {
    if ($line =~ /^\w+\s+(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+(\d+)\s+/) {
            $mon_clock = $monthash{$1};
            $day_clock = $2;
            $year_clock = $4;
            $time = $3;
            print "time: $time\n";
            last;
    }
    if(eof) {
        print "Error:no time matched in $clock\n";
        exit 0;
    }
}
close FILE;
close FILE_Clock;
my ($hour_clock,$min_clock,$sec_clock) = split(':',$time);
my $time_local_clock = timelocal($sec_clock,$min_clock,$hour_clock,$day_clock,$mon_clock-1,$year_clock-1900);
print "show NTP time: $time_local_clock\n";

my $err_str = abs($time_local_clock - $time_local);

if ($err_str >= $start_error && $err_str <= $end_error) {
    print "Success: error value is $err_str\n";
}
else {
    print "Fail: error value is $err_str\n";
}


