#!/usr/bin/perl -w
################################################################################
# File Name: concheck.pl
# Autor: Fang Ye
# Description: this script is use to check wether the console is OK
################################################################################

use strict;
use warnings;

#use diagnostics;
use Expect;
use Pod::Usage;
use Getopt::Long;
use FileHandle;

use 5.010;

##########################################################
#Global Variable defined
##########################################################

my $PASS         = 1;
my $FAIL         = 0;
my $NOTDEFINED   = "notdefined";
my $CONSOLE_OK   = 0;
my $CONSOLE_DOWN = 1;
my $TIMEOUT      = 5;
my $UNDEF        = "undefined";
my $exp;
my $rc        = $CONSOLE_DOWN;
my %userInput = (
	"tsIp"        => $NOTDEFINED,
	"consolename" => $NOTDEFINED,
	"debug"       => 0,
);
sub connect_AP {
	my $errorFlag  = 0;
	my $timeout    = $TIMEOUT;
	my @buffer     = ();
	my $returnCode = $CONSOLE_DOWN;
	my $cmd        = ();
	my $a          = 0;

	#show log buffer command have some trick when output the log message
	#we have work solution to make it work, we will add another solution
	#to fix show log buffer hang issue if necessary
	$cmd = "console  $userInput{consolename}  -M $userInput{tsIp}  -f -l root";
	printf " $cmd \n";
	$exp = Expect->spawn($cmd) or die("Cannot spawn $cmd $!\n");
	sleep 1;
	while ( $a < 4 ) {
		$a      = 4;
		@buffer = $exp->expect(
			$timeout,
			[
				qr/console is down] */,
				sub {
					$returnCode = $CONSOLE_DOWN;
					printf "--- unknown  --- - \n " if ( $userInput{debug} > 0 );
				  }
			],
			[
				qr/not found/,
				sub {
					$returnCode = $CONSOLE_DOWN;
					printf "--- unknown  --- - \n " if ( $userInput{debug} > 0 );
				  }
			],
			[

				qr/AH*/,
				sub {
					$returnCode = $CONSOLE_OK;
					printf "--- console is OK--- - \n " if ( $userInput{debug} > 0 );
				  }
			],
			[
				" for help.*",
				sub {
					if ( $errorFlag == 0 ) {
						my $fh = shift;
						$fh->send("\n");
						$errorFlag = 1;
						printf "--- errorFlag is $errorFlag --- - \n " if ( $userInput{debug} > 0 );
						$a = 1;
					}
					printf "--- a is $a --- - \n " if ( $userInput{debug} > 0 );
					$a += 1;
				  }
			],

		);
	}
	$exp->clear_accum();
	return $returnCode;
}

##########################################################
# Main Routine
##########################################################
MAIN:
my ( $option_h, $option_man );
my $logdir;

#Get Input Parameters
$rc = GetOptions(
	"help|h" => \$option_h,
	"man"    => \$option_man,
	"e=s"    => \$userInput{consolename},
	"d=s"    => \$userInput{tsIp},
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
if ( $userInput{tsIp} =~ /$NOTDEFINED/ ) {
	print("\n==>Error Missing Host server address\n\n");
	pod2usage(1);
	exit 1;
}
if ( $userInput{consolename} =~ /$NOTDEFINED/ ) {
	print("\n==>Error Missing console-name \n\n");
	pod2usage(1);
	exit 1;
}
my $index=0;
while ( $index < 4 )  {
	$rc = connect_AP();
	if ($rc == $CONSOLE_OK) {
		$index = 4;
	} else {
		$index++;
	}
	sleep 5;
}

exit $rc;

__END__

=pod

=head1 NAME

concheck.pl - Use To Configure Web Server

=head1 SYNOPSIS

=over 12

=item B<concheck.pl >
[B<-help|h>]
[B<-man>]
[B<-d> I<terminal server IP>]
[B<-e> I<testbed console name>]
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

=item B<-e>

	Specify a testbed console name( default = undefined )

=item B<-debug>

Print Debug message for engineer

=back

=head1 DESCRIPTION

B<concheck.pl> is used to check whether the console is OK
=head1 EXAMPLES

     
4. The following command is used  to check whether the tb1-AP5020N-1 is OK

        perl concheck.pl -e tb1-AP5020N-1 -d hzcs1



=head1 AUTHOR
Please report bugs sending E-mail E<lt>fye@aerohive.comE<gt>

Fang Ye<lt>franyel91@gmail.comE<gt>

=cut

