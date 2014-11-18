#!/usr/bin/perl -w
################################################################################
# File Name: sw_check.pl
# Autor: Fang Ye
# Description: this script is use to check the port status of sw
################################################################################

use strict;
use warnings;

#use diagnostics;
use Expect;
use Pod::Usage;
use Getopt::Long;
use FileHandle;

use diagnostics;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use File::Find;
use XML::Simple;
use Data::Dumper;
use Time::Local;

use 5.010;

##########################################################
#Global Variable defined
##########################################################

my $PASS       = 0;
my $FAIL       = 1;
my $NOTDEFINED = "notdefined";
my $SW_OK      = 0;
my $SW_DOWN    = 1;
my $TIMEOUT    = 5;
my $UNDEF      = "undefined";
my $exp;
my $MORE      = "\-\-More";
my $rc        = "";
my $sw_result = "";
my $result    = $FAIL;
my @msg       = "";
my %userInput = (
	"swIp"  => $NOTDEFINED,
	"debug" => 0,
);

sub connect_SW {
	my $errorFlag  = 0;
	my $timeout    = $TIMEOUT;
	my @buffer     = ();
	my $returnCode = $SW_DOWN;
	my $cmd        = ();
	my $Flag       = 0;
	my $a          = 0;

	#show log buffer command have some trick when output the log message
	#we have work solution to make it work, we will add another solution
	#to fix show log buffer hang issue if necessary
	$cmd = "telnet  $userInput{swIp}";
	printf " $cmd \n";
	$exp = Expect->spawn($cmd) or die("Cannot spawn $cmd $!\n");

	#$exp->exp_internal(0);
	#$exp->match_max(5000);
	$exp->log_user(0);
	sleep 1;
	@buffer = ();
	@buffer = $exp->expect(
		$timeout,
		[
			'Password:',
			sub {
				my $fh = shift;
				$fh->send("aerohive\n");
				printf "--- send password aerohive --- - \n " if ( $userInput{debug} > 0 );
				$exp->exp_continue;
			  }
		],
		[
			qr/console.*>/,
			sub {
				my $fh = shift;
				$fh->send("enable\n");
				printf "--- send enable - \n " if ( $userInput{debug} > 0 );
				$exp->exp_continue;
			  }
		],
		[
			'Password:',
			sub {
				my $fh = shift;
				$fh->send("aerohive\n");
				printf "--- send password aerohive --- - \n " if ( $userInput{debug} > 0 );
				$exp->exp_continue;
			  }
		],
		[

			qr/console#/,
			sub {
				my $fh = shift;
				$fh->send("show interface status\n");
				printf "--- errorFlag is $errorFlag --- - \n " if ( $userInput{debug} > 0 );

				printf "--- +++++++++--- - \n " if ( $userInput{debug} > 0 );
				$returnCode = $SW_OK;

			  }
		],
	);
	@buffer = ();
	while ( $a < 10 ) {
		$a += 2;
		@buffer = $exp->expect(
			$timeout,
			[
				'.*More',
				sub {
					my $fh = shift;
					$rc = $PASS;

					#printf " --- MORE  -A: $a-- \n" if ( $userInput{debug} > 0 );
					$returnCode = $SW_OK;
					$fh->send(" ");
					$a += 2;
				  }
			],
			[
				qr/console#/,
				sub {

					#printf "--- errorFlag is $errorFlag --- - \n\n\n " if ( $userInput{debug} > 0 );
					#printf "--- ++++A: $a+++++--- - \n " if ( $userInput{debug} > 0 );
					$returnCode = $SW_OK;
					$a          = 8;
				  }
			],

		);
		@buffer = split( "\n", ( $exp->before() . $exp->match() . $exp->after() ) );
		push( @msg, @buffer );
		@buffer = ();
	}

	$exp->clear_accum();
	return $returnCode;
}

sub result_output {

	my $stat      = "";
	my $port      = "";
	my $tmpmsg    = "";
	my $tmpjj     = "";
	my $ret_value = "";
	my @jj;
	my $a = 1;
	while ( $a < 49 ) {

		foreach $tmpmsg (@msg) {

			#printf "+++++++++++++tmpmsg is $tmpmsg++++++++++++++\n\n\n\n " if ( $userInput{debug} > 0 );
			if ( $tmpmsg =~ /(Down|Up)/ ) {

				#printf "===========+++a:$a tmpmsg is $tmpjj+++\n " if ( $userInput{debug} > 0 );
				$stat = $1;
				$port .= "g" . $a;

				#printf " ---port is $port status is $stat  --- \n" if ( $userInput{debug} > 0 );
				$sw_result .= $port . " " . $stat . "\n";
				$a++;
				$port = "";
			}

		}

	}
	return $PASS;
}

##########################################################
# Main Routine
##########################################################
MAIN:
my ( $option_h, $option_man );

#Get Input Parameters
$rc = GetOptions(
	"help|h" => \$option_h,
	"man"    => \$option_man,
	"d=s"    => \$userInput{swIp},
	"x"      => \$userInput{debug},
);

#print script usage syntax
pod2usage(1) if ($option_h);

#print man usage
pod2usage( -verbose => 2 ) if ($option_man);

#print Input parameters
if ( $userInput{debug} ) {
	foreach my $key ( keys %userInput ) {
		print("$key => $userInput{$key}\n");
	}
}

# Input parameters check
if ( $userInput{swIp} =~ /$NOTDEFINED/ ) {
	print("\n==>Error Missing Host server address\n\n");
	pod2usage(1);
	exit 1;
}
$result = connect_SW();
printf "--- result1 is $result --- - \n " if ( $userInput{debug} > 0 );
if ( $result != $PASS ) {
	exit 1;
}
$result = result_output();
printf "--- result2 is $result --- - \n " if ( $userInput{debug} > 0 );

if ( $result != $PASS ) {
	exit 1;
} else {
	printf "$sw_result\n";

}
exit 0;

__END__

=pod

=head1 NAME

sw_check.pl - Use To Configure Web Server

=head1 SYNOPSIS

=over 12

=item B<sw_check.pl >
[B<-help|h>]
[B<-man>]
[B<-d> I<terminal server IP>]

[B<-debug>]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-h>

Print a brief help message and exit.

=item B<-man>

Print a man page 

=item B<-d>

Specify a Terminal Server ip address ( default = 10.155.40.103 )

=item B<-debug>

Print Debug message for engineer

=back

=head1 DESCRIPTION

B<concheck.pl> is used to check whether the console is OK
=head1 EXAMPLES

     
4. The following command is used  to check whether the tb1-AP5020N-1 is OK

        perl sw_check.pl  -d hzsw1



=head1 AUTHOR

Please report bugs sending E-mail E<lt>fye@aerohive.comE<gt>

Fang Ye<lt>franyel91@gmail.comE<gt>

=cut

