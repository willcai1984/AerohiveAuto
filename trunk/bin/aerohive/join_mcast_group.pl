#!/usr/bin/perl -W

use strict;
use Pod::Usage;
use Getopt::Long;
use IO::Socket::Multicast;

my $man  = 0;
my $help = 0;
my $gip  = '';
my $port = 0;
my $time = 0;

our $s = '';

GetOptions(
	'h|?|help'  => \$help,
	'man'       => \$man,
	'group|g=s' => \$gip,
	'port|p=i'  => \$port,
	'time|t=i'  => \$time,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

die "Need specify multicast group IP, $!" unless $gip;

if ($port) {
    $s = IO::Socket::Multicast->new(LocalPort => $port);
}
else{
    $s = IO::Socket::Multicast->new();
}

$s->mcast_add($gip) or die "Cannot add group $gip, $!";

if ($time) {
    sleep $time;
    $s->mcast_drop($gip) or die "Cannot leave group $gip, $!";
    exit 0;
}

while(1){
    sleep 10;
}
