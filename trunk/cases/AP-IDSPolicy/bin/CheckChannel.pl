#!/usr/bin/perl -w
################################################################################
# File Name: CheckChannel.pl
# Author: Fang Ye
# Description: This script is use to parse pcap(tree format) file
################################################################################
use strict;
use warnings;
use diagnostics;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use File::Find;
use XML::Simple;
use Data::Dumper;
use Time::Local;

##########################################################
#Global Variable defined
##########################################################

my $rc;
my $FAIL        = 1;
my $PASS        = 0;
my $NOTDEFINED  = "undefined";
my @junk        = split( /\//, $0 );
my $script_name = $junk[$#junk];
$script_name =~ s/\.pl$//;
my @keywords;
my @results;
my @output;
my @sum_pkt;
my @detail_pkt;
my @packet_section_str = (
	"Arrival Time",
	"Address",
	"Beacon Interval",
	"SSID",
	"Tag interpretation",
	"Preamble",
	"Data Rate",
	"Vendor Specific"
);

my %userinput = (
	"debug" => 0,
	"file"  => $NOTDEFINED,
);

##########################################################
# sub routine get pkt via filter
##########################################################
sub pkt_filter {
	my $channel    = @_;
	my $filter_str = '^\w+|^$';
	my $field;
	my @buf;
	my @output;
	my $cnt = 0;

	my ( $value, $line, $offset );
	my %months = (
		"Jan" => 0,
		"Feb" => 1,
		"Mar" => 2,
		"Apr" => 3,
		"May" => 4,
		"Jun" => 5,
		"Jul" => 6,
		"Aug" => 7,
		"Sep" => 8,
		"Oct" => 9,
		"Nov" => 10,
		"Dec" => 11,
	);
	my ( $mday, $mon, $year, $h, $m, $s );

	my ( $skip, $line, $tmppkt );
	for ( my $i = 1 ; $i < 11 ; $i++ ) {
		$filter_str = "";
		$filter_str .= "5g ->" . $channel;		
		print "$filter_str\n" if ( $userinput{debug} );
		@buf  = `grep -E "$filter_str" -i $userinput{file}`;
		$skip = 0;
		foreach $line (@buf) {
			if ( $value =~ /(\w+)\s+(\d+),\s+(\d+)\s+(\d+):(\d+):(\d+)\.(\d+)/ )
			{
				$mday = $2;
				$mon  = $months{$1};
				$year = $3 - 1900;
				( $h, $m, $s ) = ( $4, $5, $6 );
				$output[$cnt] =
				  timelocal( $s, $m, $h, $mday, $mon, $year ) . "." . $7;
				$cnt++;
				$skip++;
			}

			if ( $skip == 2 ) {
				last;
			}
			else {
				return $FAIL;
			}
		}
		my $tmp = $output[1] - $output[0];
		if ( $tmp > 3 ) {
			return $FAIL;
		}
	}
	return $PASS;
}

MAIN:
my ( $option_h, $option_man );

#Get Input Parameters
$rc = GetOptions(
	"help|h" => \$option_h,
	"man"    => \$option_man,
	"f=s"    => \$userinput{file},
	"debug!" => \$userinput{debug},
);

#print script usage syntax
pod2usage(1) if ($option_h);

#print man usage
pod2usage( -verbose => 2 ) if ($option_man);

if ( pkt_filter() != $PASS ) {
	print "FAILED\n";
	exit 1;
}
else {
	print "SUCCESS\n";
}

exit 0;

1;
__END__

=pod

=head1 NAME

CheckChannel.pl - Use to parse wireshark capture packet file with tree format

=head1 SYNOPSIS

=over 12

=item B<CheckChannel.pl>
[B<-help|h>]
[B<-man>]
[B<-f>]
[B<-debug>]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-h>

Print a brief help message and exit.

=item B<-man>

Print a man page 

=item B<-f>

Input a pcap tree file that need to parse

=item B<-debug>

Print Debug message for engineer

=back

=head1 DESCRIPTION

B<parse_pcap.pl> This is used to parse wireshark capture packet file with tree format
return value or string for user. when specify -k and -o parameters, you need to 
specify the name according to wireshark capture packet field name.before use this
tool, you need to run station to capture packet and save in a file with tree format.
when capture a packet, we advise you don't enable host name resolve, because you
may need to use Mac address as a -k parameter to filter packet.


=head1 EXAMPLES

=head1 AUTHOR

Please report bugs sending E-mail E<lt>fye@aerohive.comE<gt>

Fang Ye E<lt>fye@aerohive.com<gt>

=cut


