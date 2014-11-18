#!/usr/bin/perl

use strict;
use warnings;

use Expect;
use Getopt::Long;
use Pod::Usage;

my $man = 0;
my $help = 0;
my $conser = '';
my $ap     = '';
my $logDir = '';
my $logfile = '';
my $conCMD = '';
my $timeout = 5;

GetOptions(
           'help|?' => \$help,
           man      => \$man,
           'c=s'    => \$conser,
           'a=s'    => \$ap,
           'l=s'    => \$logDir,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

print "$man\n$help\n$conser\n$ap\n$logDir\n";

die "Need specify Console Server!\n" unless $conser;
die "Need specify target AP!\n" unless $ap;

$conCMD = "console -M $conser $ap -l root -s";
$logfile = "$logDir/con_$ap.log";

my $exp = new Expect;
$exp->log_file($logfile);
$exp->spawn($conCMD);

sub exitFromCon{
    print "\nExit from console\n";
    $exp->send("\cEc.");
    exit;
}

$SIG{INT} = $SIG{KILL} = \&exitFromCon;

while(1){
    $exp->expect(0,
                 [
                  "\cEc\.",
                  sub{
                    }
                  ],
                );
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
