#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Net::SSH::Expect;

my $ap_img_filter = "HiveOS-5-1rX-Dakar";

my $ap = shift @ARGV;
my $lcap = lc $ap;
my $ucap = uc $ap;

my $workbee = '10.155.30.230';
my $php_script = '/var/www/html/auto_web/Module/Public/AddRegularJob.php';

my $tc = 'performance_automation.xml';
my $tb = 'hztb20';
my $br = 'Developing';
my $jv = 'distances=5;angles=0;encrypts=wpa-aes-psk;channels=1,11,36,157;' .
             'linkmodes=uplink,downlink,duallink;runtstimes=10';
my $img = '';

my $ssh = Net::SSH::Expect->new(
    host => $workbee,
    user => 'root',
    password => 'aerohive',
    raw_pty => 1,
);
$ssh->login();

$ssh->exec("rm -rf /tftpboot/newimg/*_daily.img");

my $result = $ssh->exec("ls -rt1 /tftpboot/newimg/ | grep $lcap | grep $ap_img_filter | tail -n 1");

if($result =~ m/\s+(.*\.img)\s+/){
    my $img_orig = $1;
    print "IMG: $img_orig\n";
    $img = $1;
    $img =~ s/\.img$/_daily\.img/;
    $ssh->exec("cp /tftpboot/newimg/$img_orig /tftpboot/newimg/$img");
}else{
    die "Cannot get daily image from workbee!\n";
}

print "$img\n";
print `php $php_script -tc "$tc" -tb $tb -aptype $ucap -img "$img" -b "$br" -jvar "$jv"`;

END {
    $ssh->close();
}
