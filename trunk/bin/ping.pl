#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to configure DUT with CLI via telnet/minicom. User could enter single string(s)
# from command line or from text file
# 
#
#
#--------------------------------
use strict;
use warnings;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
my $learnFn =0;
my $FAIL=0;
my $PASS=1;
my $verbose = 0;
my $NOTDEFINED="none";
#-----------------------------------------------------------
# This routine is used to check the terminal server
#-----------------------------------------------------------
sub verifyTarget {
    my ($userInput,@jj) = @_;
    my ($tsIp,$junk) = split ('\/',$userInput->{tsIp});
    my $rc = $FAIL;
    my @buffer;
    my $temp;
    my $date = `date`;
    $date =~ s/\n//g;
    my $errPercent = 50;
    my $errResult = 0;
    my $output = $userInput->{outputfile};
    my $cmd = "ping $tsIp -W 5 -c $userInput->{pktcount} ";
    if ( $userInput->{moption} !~ /$NOTDEFINED/ ) {
	$cmd = $cmd ." -M $userInput->{moption}";
    }

    if ( $userInput->{pktsize} !~ /$NOTDEFINED/ ) {
	$cmd = $cmd . " -s $userInput->{pktsize}";
    }
    print " Command = $cmd \n";
    $temp=`$cmd`;
    #$temp =~ s/\%/perc/;
    open (OUTFN,">>$output") or die ( " Could not write to $output $! ");
    print OUTFN "\[$date\]\n$temp";
    close OUTFN;
    my $msg = " $tsIp is reachable";
    @jj = split ("\n",$temp);
    my $limit= $#jj;
    my $found = 0;
    print " \n \[$limit\]\n$temp \n";
    my $match ="packet loss";
    foreach ( my $i=0 ; $i <= $limit; $i++) {
	if ( $jj[$i] =~ /$match/i ) {
	    $found = 0;
#	    if ( $jj[$i] =~ / 0perc/i ) {
	    if ( $jj[$i] =~ / packet loss/i ) {
		@buffer = split(",",$jj[$i]);
		# since there are 2 forms of result, the position must be the maximum of the entries subtracted by 1
		# 5 packets transmitted, 0 received, 100% packet loss, time 8999ms
		# 5 packets transmitted, 0 received, +4 errors, 100% packet loss, time 9000ms
		$temp=$#buffer;		
		$temp=$temp-1;
		@buffer = split ("\%",$buffer[$temp]);
		$buffer[0] =~ s/\s//;
		$found = 0;
		$errResult= $buffer[0];
		if ( $buffer[0] <= $errPercent ) {
		    $found = 2;
		}
		last;
	    } 
	    $msg = " Error: $tsIp is not reachable  =>".$jj[$i]. " $temp";
	    last;
	    
	}
    }
  SWITCH_VERIFYTARGET: for ($found ) {
      /0/ && do {
	  if ( !$userInput->{negative} ) {
	      $rc = $FAIL;
	      $msg = "Error: positive test failed ( Error percentage is $errResult >  $errPercent\% )- $tsIp is not reachable";
	  } else {
	      $rc = $PASS;
	      $msg = "Negative test passed: $tsIp is not reachable as expected ";
	  } 

	  last;
      };
      /1/ && do {
	  $rc = $FAIL;
	  last;
      };
      /2/ && do {
	  if ( !$userInput->{negative} ) {
	      $rc = $PASS;
	      $msg = "Positive test passed ( Unreacheable packets percentage is $errResult <  $errPercent\% )-- $tsIp is reachable";
	  } else {
	      $rc = $FAIL;
	      $msg = "Error : Negative test failed -- $tsIp is reachable";

	  }
	  last;
      };
      die "verifyTarget: unrecognize error code $found \n"; 
  }
    return($rc,$msg);
    
}
#------------------------------------------------------------
#
#------------------------------------------------------------
MAIN:
    my ($rc,$msg);
my %userInput = ( 
    "tsIp"=>"0.0.0.0",
    "negative"=>0,
    "debug"=>0,
    "pktsize"=>$NOTDEFINED,
    "pktcount"=> 5 ,
    "logdir"=>"./",
    "moption"=>$NOTDEFINED,
    "outputfile"=>"ping_test.log",
);
my @commands = ();
my $logdir;
my @junk;
my ($option_h,$option_man);

$rc = GetOptions( "x"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man, 
		  "d=s"=>\$userInput{tsIp},
		  "s=s"=>\$userInput{pktsize},
		  "m=s"=>\$userInput{moption},
		  "c=s"=>\$userInput{pktcount},
		  "n"=>\$userInput{negative},
		  "o=s"=>\$userInput{outputfile},
		  "l=s"=>sub {  $logdir = `cd $_[1];pwd`;$logdir=~ s/\n//; $userInput{logdir} = $logdir },
		  "v=s"=>sub { if ( exists $commands[0] ) { push (@commands,$_[1]); } else {$commands[0]=$_[1]; } } ,
		  );

#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
@junk = split ("/",$userInput{tsIp});
$userInput{tsIp} = $junk[0];
$userInput{outputfile} = $userInput{logdir}."/".$userInput{outputfile};
($rc,$msg) = verifyTarget(\%userInput,0);
print ("\n $msg \n");
if ( $rc != $PASS ) {
    exit 1;
}
exit 0;
1;
__END__

=pod

=head1 NAME

ping.pl - Send ping to DUT and interpret PASS/FAIL based on the number of error which is less than 50%. Note that to increase the percentage of success, it is recommended to send 10 packets by using "-c 10" ( by default only 5 packets was used)  

=head1 SYNOPSIS

=over 12

=item B<ping.pl>
[B<-help|-h>]
[B<-man>]
[B<-d > I<terminal server IP>]
[B<-l> I<log file path>]
[B<-v> I<cli command> [-v I<cli command>] ...]
[B<-c> I<packet count>]
[B<-m> I<do|dont|want>]
[B<-o> I<outputfile >]
[B<-s> I<packet size >]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-d>

Specify a Terminal Server ip address ( default = 192.168.35.78 )

=item B<-l >

Redirect stdout to the /path/clicfg.log if user uses "-v" parameters or "cli text file".log   

=item B<-s>

Specify packet size 

=item B<-c >

Specify the number of packets will be sent . (default is 5 ) 

=item B<-m >

Select Path MTU Discovery strategy  

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-o>

Outputfile. Default filename is ping_test.log 

=back

=head1 DESCRIPTION

B<ping.pl> will allow user to ping a DUT 


=head1 EXAMPLES

1. The following command is used to ping 4.2.2.2 and save log to /tmp/test123.txt
         perl ping.pl -d 4.2.2.2 -l /tmp -o test123.txt

2. The following command is used to ping 4.2.2.2 and save log to /tmp/ping_test.log which is the default name
         perl ping.pl -d 4.2.2.2 -l /tmp 


3. The following command is used to ping 4.2.2.2 with 10 packets and  save log to /tmp/ping_ttest.log and 
         perl ping.pl -d 4.2.2.2 -c 10 -l /tmp 



=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
