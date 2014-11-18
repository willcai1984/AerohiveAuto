#!/usr/bin/perl -w
##----------------------
#stringify the variables into format:
#distance:angle:encrypt:channel,distance:angle:encrypt:channel..
##----------------------
use strict;
use Data::Dumper;
use Getopt::Long;

my $help = 0;
my $man = 0;
#set default value for each variable
my $distances = '5';
my $angles = '0';
my $encrypts = 'wpa-aes-psk';
my $channels = '1,11,36,157';

GetOptions(
    'help|?'      => \$help,
	man           => \$man,
    'distances=s' => \$distances,
    'angles=s'    => \$angles,
    'encrypts=s'  => \$encrypts,
    'channels=s'  => \$channels,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

#print "distances: $distances\n";
#print "angles: $angles\n";
#print "encrypts: $encrypts\n";
#print "channels: $channels\n";

my @dist = split / *, */, $distances;
my @angl = split / *, */, $angles;
my @encp = split / *, */, $encrypts;
my @chnl = split / *, */, $channels;

my @arr = ();
foreach my $dis (@dist){
    foreach my $ang (@angl){
        foreach my $enc (@encp){
            push @arr, map { "$dis:$ang:$enc:$_" } @chnl;
        }
    }
}

#print Dumper(\@arr);
my $str = join ",", @arr;
print "$str\n";