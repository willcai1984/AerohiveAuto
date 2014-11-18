#!/usr/bin/perl
use strict;
use warnings;
use Net::SCP::Expect;

my $img = shift @ARGV;
die "Need specify image name!\n" unless $img;

#print "img name: $img\n\n";

my $local_img = `ls /tftpboot |grep $img`;
#print "$local_img\n\n";
if($local_img){
    print "local: $local_img\n";
    exit 0;
}

my $scp = Net::SCP::Expect->new(
    user => 'root',
    password => 'aerohive',
    auto_yes => 1,
);
$scp->scp("10.155.30.230:/tftpboot/newimg/$img", "/tftpboot");