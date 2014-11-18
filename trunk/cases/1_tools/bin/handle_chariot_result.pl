#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use Getopt::Long;

my $man = 0;
my $help = 0;
my $file = '';

GetOptions(
    'help|?' => \$help,
	man      => \$man,
    'f|file=s' => \$file,  
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

print "File: $file\n";

my $throughput_avg = 0;
open RESULT, "<", $file;
while(<RESULT>){
    next unless m/All Pairs/i;
    chomp;
    my @tmp = split /,/;
    $throughput_avg = $tmp[9];
    print "All Pairs throughput Avg: $throughput_avg\n";
}
close RESULT;