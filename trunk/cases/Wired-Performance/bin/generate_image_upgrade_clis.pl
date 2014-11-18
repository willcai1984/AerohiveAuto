#!/usr/bin/perl -w
use strict;

use 5.010;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

my $man  = 0;
my $help = 0;
my $casename = '';
my $br100    = '';
my $br200    = '';
my $sr2024   = '';
my $sr2024p  = '';
my $sr2124p  = '';
my $sr2148p  = '';
my $ap340    = '';
my $ap350    = '';
my $ap390    = '';
my $ap230    = '';
my $ap1130   = '';
my $snake    = '';
my $sw       = '';
my $cvg      = '';

my $duttype = '';
my $output  = '';

GetOptions(
    'help|?' => \$help,
    man      => \$man,
    'casename|c=s' => \$casename,
    'br100img=s'   => \$br100,
    'br200img=s'   => \$br200,
    'sr2024img=s'  => \$sr2024,
    'sr2024pimg=s' => \$sr2024p,
    'sr2124pimg=s' => \$sr2124p,
    'sr2148pimg=s' => \$sr2148p,
    'ap340img=s'   => \$ap340,
    'ap350img=s'   => \$ap350,
    'ap390img=s'   => \$ap390,
    'ap230img=s'   => \$ap230,
	'ap1130img=s'  => \$ap1130,
    'snakeimg=s'   => \$snake,
    'swimg=s'      => \$sw,
    'cvgimg=s'     => \$cvg,
);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

die "Error -> need specify case name\n" unless $casename;

if($casename =~ m/^(\w+)_/){
    $duttype = $1;
}
else{
    die "Error -> cannot parse dut type from case name";
}

if($casename =~ m/_vpn/){
    print "needCVG=true\n";
    if($cvg){
        print "needUpgradeCVG=true\n";
        print "tb.cvg1.shellpwd=2Xit8B0sOI5QFpfA\n";
    }
}

sub br100_print_cli{
    my $dut1_img = shift;
    if($dut1_img){
        $output = <<END;
needUpgradeDUT=true
sw1.cli=-v "no interface eth1/1 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-br100-1
dut1.imgName=$dut1_img
dut1.shellpwd=6CPhkYKVRqE4520E
END
    }
    else{
        $output = "dut1.consname=wp-br100-1\n";
    }
    print $output;
}

sub br200_print_cli{
    my $dut1_img = shift;
    if($dut1_img){
        $output = <<END;
needUpgradeDUT=true
sw1.cli=-v "no interface eth1/2 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-br200-1
dut1.imgName=$dut1_img
dut1.shellpwd=kY6HuM3Sjeoh38OL
END
    }
    else{
    $output = "dut1.consname=wp-br200-1\n";
    }
    print $output; 
}

sub sr2024p_print_cli{
    my $dut1_img = shift;
    if($dut1_img){
        $output = <<END;
needUpgradeDUT=true
sw1.cli=-v "no interface eth1/9 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-sr2024p-1
dut1.imgName=$dut1_img
dut1.shellpwd=TsKpWAYVwmA3HF4y
END
    }
    else{
        $output = "dut1.consname=wp-sr2024p-1\n";
    }
    print $output;
}

sub sr2124p_print_cli{
    my $dut1_img = shift;
    if($dut1_img){
        $output = <<END;
needUpgradeDUT=true
sw1.cli=-v "no interface eth1/10 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-sr2124p-1
dut1.imgName=$dut1_img
dut1.shellpwd=A1cCOIAE06qXLLvq
END
    }
    else{
        $output = "dut1.consname=wp-sr2124p-1\n";
    }
    print $output; 
}

sub ap340_print_cli{
    my $dut1_img = shift;
    my $dut2_img = shift;
    if($dut1_img || $dut2_img){
        $output = <<END;
needUpgradeDUT=true
sw1.cli=-v "no interface eth1/3 shutdown" -v "no interface eth1/4 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-ap340-1
dut1.imgName=$dut1_img
dut1.shellpwd=yImeMRb5hnSgIMu0
dut2.consname=wp-ap340-2
dut2.imgName=$dut2_img
dut2.shellpwd=3jsG1kn0XLfFS3pi
END
    }
    else{
        $output = <<END;
dut1.consname=wp-ap340-1
dut2.consname=wp-ap340-2
END
    }
    print $output;
}

sub ap350_print_cli{
    my $dut1_img = shift;
    my $dut2_img = shift;
    if($dut1_img || $dut2_img){
        $output = <<END;
needUpgradeDUT=true
sw1.cli=-v "no interface eth1/5 shutdown" -v "no interface eth1/6 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-ap350-1
dut1.imgName=$dut1_img
dut1.shellpwd=YQnOECBaFkad5ENT
dut2.consname=wp-ap350-2
dut2.imgName=$dut2_img
dut2.shellpwd=cDSvjPpFlXe1Iyvq
END
    }
    else{
        $output = <<END;
dut1.consname=wp-ap350-1
dut2.consname=wp-ap350-2
END
    }
    print $output;
}

sub ap390_print_cli{
    my $dut1_img = shift;
    my $dut2_img = shift;
    if($dut1_img || $dut2_img){
        $output = <<END;
needUpgradeDUT=true
imgName=$ap390
sw1.cli=-v "no interface eth1/7 shutdown" -v "no interface eth1/8 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-ap390-1
dut1.imgName=$dut1_img
dut1.shellpwd=BqhFki3L5khr2q6U
dut2.consname=wp-ap390-2
dut2.imgName=$dut2_img
dut2.shellpwd=5CyoEPC3OH6ELltt
END
    }
    else{
        $output = <<END;
dut1.consname=wp-ap390-1
dut2.consname=wp-ap390-2
END
    }
    print $output;
}

sub ap230_print_cli{
    my $dut1_img = shift;
    my $dut2_img = shift;
    if($dut1_img || $dut2_img){
        $output = <<END;
needUpgradeDUT=true
imgName=$ap230
sw1.cli=-v "no interface eth1/11 shutdown" -v "no interface eth1/12 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-ap230-1
dut1.imgName=$dut1_img
dut1.shellpwd=QQfBf2NkBwwPrdY0
dut2.consname=wp-ap230-2
dut2.imgName=$dut2_img
dut2.shellpwd=Fhd6X83sofYC0RF1
END
    }
    else{
        $output = <<END;
dut1.consname=wp-ap230-1
dut2.consname=wp-ap230-2
END
    }
    print $output;
}

sub ap1130_print_cli{
    my $dut1_img = shift;
    my $dut2_img = shift;
	my $dut3_img = shift;
    if($dut1_img || $dut2_img || $dut3_img){
        $output = <<END;
needUpgradeDUT=true
sw1.cli=-v "no interface eth1/13 shutdown" -v "no interface eth1/11 shutdown" -v "no interface eth1/6 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-ap1130-1
dut1.imgName=$dut1_img
dut1.shellpwd=4Ev67vTCllPtTsld
dut2.consname=wp-ap230-1
dut2.imgName=$dut2_img
dut2.shellpwd=QQfBf2NkBwwPrdY0
dut3.consname=wp-ap350-2
dut3.imgName=$dut3_img
dut3.shellpwd=cDSvjPpFlXe1Iyvq
END
    }
    else{
        $output = <<END;
dut1.consname=wp-ap1130-1
dut2.consname=wp-ap230-1
dut3.consname=wp-ap350-2
END
    }
    print $output;
}

sub snake_print_cli{
    my $dut1_img = shift;
    my $dut2_img = shift;
    my $dut3_img = shift;
    my $dut4_img = shift;
    if($dut1_img || $dut2_img || $dut3_img || $dut4_img){
        $output = <<END;
needUpgradeDUT=true
sw1.cli=-v "no interface eth1/20 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-snake-2024p
dut1.imgName=$dut1_img
dut1.shellpwd=Hg1Xutl2cXP8U0PB
dut2.consname=wp-snake-2124p
dut2.imgName=$dut2_img
dut2.shellpwd=7w03UWCGenW1OM8J
dut3.consname=wp-snake-2148p
dut3.imgName=$dut3_img
dut3.shellpwd=FyJ1nAOfpd5AyagR
dut4.consname=wp-snake-2024
dut4.imgName=$dut4_img
dut4.shellpwd=BFQWWxmxR8j2CD2s
END
    }
    else{
        $output = <<END;
dut1.consname=wp-snake-2024p
dut2.consname=wp-snake-2124p
dut3.consname=wp-snake-2148p
dut4.consname=wp-snake-2024
END
    }
    print $output; 
    
}

given($duttype){
    when(m/br100/i){
        br100_print_cli($br100);
    }
    when(m/br200/i){
        br200_print_cli($br200);
    }
    when(m/sr2024p/i){
        if($sr2024p){
            sr2024p_print_cli($sr2024p);
        }
        elsif($sw){
            sr2024p_print_cli($sw);
        }
        else{
            sr2024p_print_cli();
        }
    }
    when(m/sr2124p/i){
        if($sr2124p){
            sr2124p_print_cli($sr2124p);
        }
        elsif($sw){
            sr2124p_print_cli($sw);
        }
        else{
            sr2124p_print_cli();
        }
    }
    when(m/ap340/i){
        ap340_print_cli($ap340, $ap340);
    }
    when(m/ap350/i){
        ap350_print_cli($ap350, $ap350);
    }
    when(m/ap390/i){
        ap390_print_cli($ap390, $ap390);
    }
    when(m/ap230/i){
        ap230_print_cli($ap230, $ap230);
    }
	when(m/ap1130/i){
        ap1130_print_cli($ap1130, $ap230, $ap350);
    }
    when(m/snake/i){
        #dut1.consname=wp-snake-2024p
        #dut2.consname=wp-snake-2124p
        #dut3.consname=wp-snake-2148p
        #dut4.consname=wp-snake-2024
        $sr2024p = $snake ? $snake : $sw unless $sr2024p;
        $sr2124p = $snake ? $snake : $sw unless $sr2124p;
        $sr2148p = $snake ? $snake : $sw unless $sr2148p;
        $sr2024  = $snake ? $snake : $sw unless $sr2024;
        snake_print_cli($sr2024p, $sr2124p, $sr2148p, $sr2024);
    }
}



__END__

=head1 NAME

    sample - Using GetOpt::Long and Pod::Usage

=head1 SYNOPSIS

    sample [options] [file ...]
     Options:
       -help            brief help message
       -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do someting
useful with the contents thereof.

=cut
