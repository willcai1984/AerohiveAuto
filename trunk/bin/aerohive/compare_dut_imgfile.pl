#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

use DateTime::Duration;
use DateTime::Format::HTTP;

my $man  = 0;
my $help = 0;
my $vfile = '';
my $ifile = '';

GetOptions(
    'help|?' => \$help,
    man      => \$man,
    'vfile=s' => \$vfile,
    'ifile=s' => \$ifile,
);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

sub is_buildtime_diff{
    my $time1 = shift;
    my $time2 = shift;
    
    my $d1 = DateTime::Format::HTTP->parse_datetime($time1);
    my $d2 = DateTime::Format::HTTP->parse_datetime($time2);
    ($d1, $d2) = ($d2, $d1) if $d1 > $d2;
    my $interval = DateTime::Duration->new(minutes => 1);
    
    if($d2 - $interval < $d1){
        return 0;
    }
    else{
        return 1;
    }
}

sub is_image_same{
    my ($img1, $img2) = @_;
    
    if($img1->{'ver'} ne $img2->{'ver'}){
        return 0;
    }
    elsif(is_buildtime_diff($img1->{'time'}, $img2->{'time'})){
        return 0;
    }
    else{
        return 1;
    }
}

#image version, image build time
my %img = (ver => '', time => '',);
open IFILE, "<", $ifile or die "Cannot open file: $ifile, $!";
while(<IFILE>){
    if(m/Reversion:\s+([\d\.]+)\.\d+\s+/){
        $img{'ver'} = $1;
        next;
    }
    if(m/DATE:\s+([\w :]+)\s+\$/){
        $img{'time'} = $1;
        last;
    }
}
close IFILE;

#ap current version, build time and backup version, build time
my %dut_cimg = (ver => '', time =>'');
my %dut_bimg = (ver => '', time =>'');
open VFILE, "<", $vfile or die "Cannot open file: $vfile, $!";
while(<VFILE>){
    #As cvg image start with "Version", not "Current Version"
    if(m/(?:Current version|Version):\s+HiveOS\s+([\w\.]+) release /){
        $dut_cimg{'ver'} = $1;
        $dut_cimg{'ver'} =~ s/r/./;
        while(<VFILE>){
            if(m/Build time:\s+([\w :]+)/){
                $dut_cimg{'time'} = $1;
                last;
            }
        }
    }
    if(m/Backup version:\s+HiveOS\s+([\w\.]+)/){
        $dut_bimg{'ver'} = $1;
        $dut_bimg{'ver'} =~ s/r/./;
        while(<VFILE>){
            if(m/Build time:\s+([\w :]+)/){
                $dut_bimg{'time'} = $1;
                last
            }
        }
        last;
    }
}
close VFILE;

#dual image
if($dut_bimg{'ver'}){
    if(is_image_same(\%img, \%dut_cimg)){
        print "NOCHANGE";
        exit 0;
    }
    elsif(is_image_same(\%img, \%dut_bimg)){
        print "REBOOTBACKUP";
        exit 0;
    }
    else{
        print "UPGRADE";
    }
}
#single image
else{
    if(is_image_same(\%img, \%dut_cimg)){
        print "NOCHANGE";
    }
    else{
        print "UPGRADE";
    }
}


