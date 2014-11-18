#!/usr/bin/perl -w
#-----------------------------------------
# Please report bug to hcheng@aerohive.com
#-----------------------------------------
#exit code explanation
#0 running OK
#1 cannot find country code
#2 csv file issue

use strict;
use Pod::Usage;
use Data::Dumper;
use Getopt::Long;

my $man    = 0;
my $help   = 0;
my $debug  = 0;
my $config = '';
my $ccode  = 0;
my $get_cy_list = 0;
my @wifi1_full_ch = qw(36 40 44 48 52 56 60 64 100 104 108 112 116 120 124 128 132 136 140 149 153 157 161 165);
my @wifi1_supp_ch = ();

#Variables need to export
my $cy_name        = '';
my $cy_region      = '';
my $cy_wifi0_chnnl = '';
my $cy_dfs_support = '';

sub calc_w1_chnnl_log{
    my @tmp = @{shift @_};
    #split channel into 4 segment
    my ($arr1, $arr2, $arr3, $arr4) = ();
    foreach my $ch (@tmp){
        if($ch < 52){
            push @$arr1, $ch;
        }
        elsif($ch < 100){
            push @$arr2, $ch;
        }
        elsif($ch < 149){
            push @$arr3, $ch;
        }
        else{
            push @$arr4, $ch;
        }
    }
    
    foreach my $seg ($arr1, $arr2, $arr3, $arr4){
        my $dfs = '';
        if(defined($seg->[0])){
            $dfs = ($seg->[0] > 48 && $seg->[0] < 149) ? '.*DFS' : '';
        }
        #my @chs = @{$seg};
        my $index = 0;
        while(defined($seg->[$index])){
            my $up = $seg->[$index];
            if(defined($seg->[$index +1 ])){
                my $low = $seg->[$index + 1];
                if($low - $up == 4){
                    print "cy.ch_log_$up=\.*40U$dfs\n";
                    print "cy.ch_log_$low=\.*40L$dfs\n";
                    $index += 2;
                    next;
                }else{
                    print "cy.ch_log_$up=$dfs\n";
                    $index++;
                    next;
                }
            }else{
                print "cy.ch_log_$up=$dfs\n";
                $index++;
            }
        }
    }
}
#&calc_w1_chnnl_log(\@wifi1_supp_ch);

GetOptions(
    'help|?'    => \$help,
    man         => \$man,
    'conf|f=s'  => \$config,
    'ccode|c=s' => \$ccode,
    'debug|d'   => \$debug,
    'get_country_list|l' => \$get_cy_list,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

my @arr = ();
my @ccode_list = ();
my $find_cy = 0;
open CONF, "<", $config;
while(<CONF>){
    s/[\r\n]//g;
    @arr = split /,/, $_;
    if($get_cy_list && defined($arr[2]) && $arr[2] =~ m/Support Channel\(dbm\)/i){
        push @ccode_list, $arr[1] if(defined($arr[1]) && $arr[1] =~ m/\d+/);
    }
    elsif(defined($arr[1]) && $arr[1] eq $ccode){
        print "find the country, country code: $ccode\n" if $debug;
        $find_cy = 1;
        last;
    }
}
close CONF;

if($get_cy_list){
    print join(",", @ccode_list);
    exit 0;
}
if(!$find_cy){
    print "Can not get country $ccode from $config\n" if $debug;
    exit 1;
}

#{
#    my $i = 0;
#    while(defined $arr[$i]){
#        print "$i: $arr[$i]\n";
#        $i++;
#    }
#}
#parse country name
$cy_name = $arr[0];

#Only USA's region is FCC, other countries are World
$cy_region = ($ccode == 840) ? 'FCC' : 'World';

#parse wifi0 channel 11 or 13
if($arr[14] eq '¡Á' && $arr[15] eq '¡Á'){
    $cy_wifi0_chnnl = '11';
}
elsif($arr[14] eq '¡Ì' && $arr[15] eq '¡Ì'){
    $cy_wifi0_chnnl = '13';
}
else{
    print "Config file error, country: $cy_name\n$arr[14]\n$arr[15]\n" if $debug;
    exit 2;
}
#parse DFS support
if($arr[20] eq 'NA' && $arr[34] eq 'NA'){
    $cy_dfs_support = 'false';
    }
elsif($arr[20] =~ m/¡Ì|¡Á/ && $arr[34] =~ m/¡Ì|¡Á/){
    $cy_dfs_support = 'true';
}
else{
    print "Config file error, country: $cy_name\n$arr[20]\n$arr[34]\n" if $debug;
    exit 2;
}

print<<SETVAR;
cy.code=$ccode
cy.name=$cy_name
cy.region=$cy_region
cy.wifi0_chnnl=$cy_wifi0_chnnl
cy.dfs_supported=$cy_dfs_support
SETVAR
#parse wifi1 channel
my $index = 16;
foreach my $ch (@wifi1_full_ch){
    #print $arr[$index], "\n";
    if($arr[$index] eq '¡Ì'){
        push @wifi1_supp_ch, $ch;
        print "cy.ch_$ch=yes\n";
    }
    elsif($arr[$index] eq '¡Á' || $arr[$index] eq 'NA'){
        print "cy.ch_$ch=\n";
    }
    else{
        print "Config file error, country: $cy_name, channel: $ch\n$arr[$index]\n"
          if $debug;
        exit 2;
    }
    $index++;
}
&calc_w1_chnnl_log(\@wifi1_supp_ch);

__END__

=head1 NAME

    dfs_auto_parse_country.pl - parse channel support status according country code.

=head1 SYNOPSIS

    dfs_auto_parse_country.pl [options]
    Options:
    --help            brief help message
    --man             full documentation
    --conf|-f         channel configuration file
    --ccode|-c        country code
    --debug|-d        print debug message


=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<--conf|-f>

Specify the channel config file, which must be CSV files saved from Microsoft xlsx files.

=item B<--ccode|-c>

Specify country code

=item B<--debug|-d>

Open debug flag and show more detail message

=back

=head1 DESCRIPTION

B<This program> will read the given input file(s) and country code, and then return
channels the country support. The return format match the requirement of <multi-setvar>

=cut
