#!/usr/bin/perl -w
use strict;

sub strtime{
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
    $mon += 1;
    return "$year-$mon-$mday-$hour-$min";
}

my $script = shift @ARGV;
my $workdir = 'D:\\performance';
my $prefix = strtime();
my $newfolder = "$workdir\\" . $prefix;
mkdir $newfolder;
chdir $newfolder;

my $resulttst = "$newfolder\\$prefix-result.tst";
if(-e $script){
    system("runtst $script $resulttst -t 60");
}else{
    die "Error: cannot find chariot script file!\n";
}

my $resultcsv = "$newfolder\\$prefix-result.csv";
if(-e $resulttst){
    system("fmttst -v $resulttst $resultcsv");
}else{
    die "Error: cannot find result TST file!\n";
}

#parse throughput and rssi from csv result file
if(-e $resultcsv){
    my $throughput_avg = 0;
    open RESULT, "<", $resultcsv;
    while(<RESULT>){
        next unless m/All Pairs/i;
        chomp;
        my @tmp = split /,/;
        $throughput_avg = $tmp[9];
        print "All Pairs throughput Avg: $throughput_avg\n";
    }
    close RESULT;
}else{
    die "Error: cannot find result CSV file!\n";
}
#`runtst `
