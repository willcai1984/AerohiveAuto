#!/usr/bin/perl -w
################################################################################
# File Name: check_subnet.pl
# Autor: Lifang Tang
# Description: this script is use to check the subnet status
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

my $PASS=0;
my $FAIL=1;
my $NOTDEFINED="notdefined";
my $SW_OK = 0;
my $SW_DOWN = 1;
my $TIMEOUT = 5;
my $UNDEF   = "undefined";
my $exp;
my $MORE  = "\-\-More";
my $rc = "";
my $sw_result = "";
my $result = $FAIL;
my @msg = "";
my %userInput = ( 
        "swIp"=>$NOTDEFINED,
        "pingIp"=>$NOTDEFINED,
        "user"=>$NOTDEFINED,
        "debug"=>0,
);

sub check_subnet {
	my $errorFlag = 0;
	my $timeout   = $TIMEOUT;
	my @buffer    = ();
	my $returnCode = $SW_DOWN;
	my $cmd = ();
	my $Flag = 0;
	#show log buffer command have some trick when output the log message
	#we have work solution to make it work, we will add another solution
	#to fix show log buffer hang issue if necessary
	$cmd = "ssh  $userInput{user}\@$userInput{swIp}";
	printf " $cmd \n";
	$exp = Expect->spawn($cmd) or die("Cannot spawn $cmd $!\n");
	$exp->log_user(0);
	sleep 1;
	@buffer = ();
	@buffer = $exp->expect(			
			$timeout,
			[
				"password:",
				sub {
					my $fh = shift;
					$fh->send("aerohive\n");
					printf "--- send password aerohive --- - \n " if ( $userInput{debug} > 0 );
					$exp->exp_continue;
				}
			],
			[
				'0\% packet loss',
				sub {
					printf "---0  packet loss --- - \n " if ( $userInput{debug} > 0 );
					
					$returnCode = $SW_OK;	
				}
			],
			[

				"#",
				sub {
					my $fh = shift;
					$fh->send("ping $userInput{pingIp} -c 1\n");
					printf "--- errorFlag is $errorFlag --- - \n " if ( $userInput{debug} > 0 );
					
					printf "--- +++++++++--- - \n " if ( $userInput{debug} > 0 );
					$exp->exp_continue;	
									
					
				}
			],
	);	
	$exp->clear_accum();
	return  $returnCode;
}


##########################################################
# Main Routine
##########################################################
MAIN:
my ($option_h, $option_man);

#Get Input Parameters
$rc = GetOptions(
	"help|h"=>\$option_h,
	"man"=>\$option_man,
	"u=s"=>\$userInput{user},
	"d=s"=>\$userInput{swIp},
	"p=s"=>\$userInput{pingIp},
	"x"=>\$userInput{debug},
);

#print script usage syntax
pod2usage(1) if ($option_h);

#print man usage
pod2usage(-verbose=>2) if ($option_man);

#print Input parameters
if ($userInput{debug}){
        foreach my $key ( keys %userInput ) {
                print ("$key => $userInput{$key}\n"); 
        }
}

# Input parameters check
if ($userInput{user} =~ /$NOTDEFINED/) {
        print ("\n==>Error Missing Username\n\n");
        pod2usage(1);
        exit 1;
}
if ($userInput{swIp} =~ /$NOTDEFINED/) {
        print ("\n==>Error Missing Host server address\n\n");
        pod2usage(1);
        exit 1;
}
if ($userInput{pingIp} =~ /$NOTDEFINED/) {
        print ("\n==>Error Missing subnet IP\n\n");
        pod2usage(1);
        exit 1;
}
$result = check_subnet();
printf "--- result is $result --- - \n " if ( $userInput{debug} > 0 );

if ($result != $PASS ) {
	exit 1;
} else {
	printf "$sw_result\n";
	
}
exit 0;


__END__

=pod

=head1 NAME

check_subnet.pl - Use To check subnet status

=head1 SYNOPSIS

=over 12

=item B<sw_check.pl >
[B<-help|h>]
[B<-man>]
[B<-u> I<Username>]
[B<-d> I<terminal server IP>]
[B<-p> I<subnet IP>]

[B<-debug>]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-h>

Print a brief help message and exit.

=item B<-man>

Print a man page 

=item B<-d>

Specify a master ip address ( default = 10.155.40.103 )

=item B<-u>

Specify a username ( default = root )

=item B<-p>

Specify a ping ip address ( default = 192.168.11.1 )

=item B<-debug>

Print Debug message for engineer

=back

=head1 DESCRIPTION

B<check_subnet.pl> is used to check whether the subnet is OK
=head1 EXAMPLES

     
4. The following command is used  to check whether the subnet 192.168.11.1 is OK

        perl sw_check.pl -u root  -d 10.155.40.141 -p 192.168.11.1



=head1 AUTHOR

Please report bugs sending E-mail E<lt>ltang@aerohive.comE<gt>

Lifang Tang<lt>tang.green@gmail.comE<gt>

=cut

