#!/usr/bin/perl -w
use strict;

use 5.010;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

my $man  = 0;
my $help = 0;
my $casename = '';


my $duttype = '';
my $needcvg = 0;
my $output  = '';

GetOptions(
    'help|?' => \$help,
    man      => \$man,
    'casename|c=s' => \$casename,
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

if($casename =~ m/vpn/i){
    $needcvg = 1;
}

sub print_cli_br100{
    $output = <<END;
needUpgradeDUT=true
imgName=$br100
sw1.cli=-v "no interface eth1/1 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-br100-1
dut1.shellpwd=6CPhkYKVRqE4520E
END
    print $output;
}

sub print_cli_br200{
    $output = <<END;
needUpgradeDUT=true
imgName=$br200
sw1.cli=-v "no interface eth1/2 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-br200-1
dut1.shellpwd=CvlqJV7JeIIwXclV
END
    print $output; 
}

sub print_cli_sr2024{
    my $img = shift;
    $output = <<END;
needUpgradeDUT=true
imgName=$img
sw1.cli=-v "no interface eth1/9 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-sr2024-1
dut1.shellpwd=
END
    print $output;
}

sub print_cli_sr2124p{
    my $img = shift;
    $output = <<END;
needUpgradeDUT=true
imgName=$img
sw1.cli=-v "no interface eth1/10 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-sr2124p-1
dut1.shellpwd=
END
    print $output; 
}

sub print_cli_ap340{
    $output = <<END;
needUpgradeDUT=true
imgName=$ap340
sw1.cli=-v "no interface eth1/3 shutdown" -v "no interface eth1/4 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-ap340-1
dut1.shellpwd=dD2GA2kIcwSASNAb
dut2.consname=wp-ap340-2
dut2.shellpwd=3jsG1kn0XLfFS3pi
END
    print $output;
}

sub print_cli_ap350{
    $output = <<END;
needUpgradeDUT=true
imgName=$ap350
sw1.cli=-v "no interface eth1/5 shutdown" -v "no interface eth1/6 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-ap350-1
dut1.shellpwd=YQnOECBaFkad5ENT
dut2.consname=wp-ap350-2
dut2.shellpwd=cDSvjPpFlXe1Iyvq
END
    print $output;
}

sub print_cli_ap370{
    $output = <<END;
needUpgradeDUT=true
imgName=$ap370
sw1.cli=-v "no interface eth1/7 shutdown" -v "no interface eth1/8 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-ap370-1
dut1.shellpwd=
dut2.consname=wp-ap370-2
dut2.shellpwd=
END
    print $output;
}

sub print_cli_snake{
    my $img = shift;
    $output = <<END;
needUpgradeDUT=true
imgName=$img
sw1.cli=-v "no interface eth1/20 shutdown" -v "no interface eth1/24 shutdown"
dut1.consname=wp-snake-sr2024p
dut1.shellpwd=jjrJhn7XRVK3nrqD
dut2.consname=wp-snake-sr2024
dut2.shellpwd=H2aIy2mvsMCWNa6W
dut3.consname=wp-snake-sr2148p
dut3.shellpwd=Dp21Bd7E3wkPvi4D
dut4.consname=wp-snake-sr2124p
dut4.shellpwd=6nFu567TsHctrGGq
END
    print $output; 
    
}

given($duttype){
    when(m/br100/i){
        print_cli_br100();
    }
    when(m/br200/i){
        print_cli_br200();
    }
    when(m/sr2024/i){
        print_cli_sr2024();
    }
    when(m/sr2124p/i){
        print_cli_sr2124p();
    }
    when(m/ap340/i){
        print_cli_ap340();
    }
    when(m/ap350/i){
        print_cli_ap350();
    }
    when(m/ap370/i){
        print_cli_ap370();
    }
    when(m/snake/i){
        print_cli_snake();
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
