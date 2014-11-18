#!/usr/bin/perl -w
use strict;

use Pod::Usage;
use Data::Dumper;
use Getopt::Long;

sub trim{
    my $str = shift;
    $str =~ s/^\s*//;
    $str =~ s/\s*$//;
    return $str;
}

my $man = 0;
my $help = 0;
my $log = '';
my $conf = '';

GetOptions(
    'help|?'   => \$help,
    man        => \$man,
    'log|l=s'  => \$log,
    'conf|c=s' => \$conf,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

#option sanity check
die "Need specify the show tech log file\n" unless $log;
die "Need specify the configuration file\n" unless $conf;
print "--log $log\n";
print "--conf $conf\n";

open LOG, "<", $log;
chomp(my @show_tech = <LOG>);
close LOG;
@show_tech = grep { m/^Show|^_test|^Test/i } @show_tech;
#print Dumper(\@show_tech);

open CONF, "<", $conf;
chomp(my @config = <CONF>);
close CONF;

my @show_comp = sort { $a cmp $b } map { trim($_) } @show_tech;
my @conf_comp = sort { $a cmp $b } map { trim($_) } @config;
@conf_comp = grep { m/^Show|^_test|^Test/i } @conf_comp;
my $exitcode = 0;
print "\n***Find config lines in log file:\n";
foreach my $c (@conf_comp){
    my $find = 0;
    foreach my $s (@show_comp){
        if($c eq $s){
            $find = 1;
            print "Found: $c\n";
            last;
        }
        else{
            next;
        }
    }
    if(!$find){
        print "Miss: $c\n";
        $exitcode = 1;
    }
}

print "\n***Find show tech line in config file:\n";
foreach my $s (@show_comp){
    my $find = 0;
    foreach my $c (@conf_comp){
        if($s eq $c){
            $find = 1;
            last;
        }
        else{
            next;
        }
    }
    if(!$find){
        print "Miss: $s\n";
        $exitcode = 1;
    }
}

exit $exitcode;

__END__

=head1 NAME

    show_tech_compare.pl - compare show tech output with config files

=head1 SYNOPSIS

    show_tech_compare.pl [options] [file ...]
    Options:
    -help            brief help message
    -man             full documentation
    --log|-l         log file of AP's "show tech"
    --conf|-c        config file

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

=cut
