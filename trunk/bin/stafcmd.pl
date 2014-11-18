#!/usr/bin/perl -w
#---------------------------------------------------------------
#Name: Joe Nguyen
#Description:
# This script is used to send command through STAF service
#
#
#---------------------------------------------------------------

use strict;
use warnings;
use diagnostics;
use Expect;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use XML::Simple;
use Data::Dumper;
use Log::Log4perl;
use Expect;
use PLSTAF;

my $learnFn       = 0;
my $NO_FILE       = "Not_specified";
my $NOTDEFINED    = "not_defined";
my $ON            = 1;
my $OFF           = 0;
my $PASS          = 1;
my $FAIL          = 0;
my $CLI_TMO       = 1;
my $CLI_PROMPT    = 2;
my $CLI_ILLEGAL   = 3;
my $EXP_DELIMITER = "@";
my $SETUP_IF_TMO  = 10 * 60;             # 5 minutes
my $CMD_TMO       = 60;
my $verbose       = 0;
my $NOFUNCTION    = "no function";
my @junk          = split( /\//, $0 );
@junk = split( '\.', $junk[$#junk] );
my $scriptFn = $junk[0];

my %userInput = (
	"user"       => "root",
	"password"   => "password",
	"debug"      => "0",
	"logdir"     => "./",
	"dutIp"      => "127.0.0.1",
	"filename"   => $NO_FILE,
	"scriptname" => $scriptFn,
	"screenOff"  => 0,
	"logOff"     => 0,
	"resultFN"   => 0,
	"outputfile" => $NOTDEFINED,
	"commands"   => [],
	"stafhandle" => 0,
	"switchtype" => {},

);

#-----------------------------------------------------------
# This routine is used to get the base name
#-----------------------------------------------------------

sub getBaseName {
	my ( $path, $junk ) = @_;
	my @t1;
	@t1 = split( "/", $path );
	$junk = $t1[$#t1];
	return ($junk);
}

#-----------------------------------------------------------
# This routine is used to check if target is recheable
#-----------------------------------------------------------
sub verifyTarget {
	my ( $profFile, $tsIp ) = @_;
	my $log = $profFile->{logger};
	my $rc  = 0;
	my @jj;
	my $output = "ping $tsIp -w 5 -c 5";
	$log->info("$output");
	my $cmd = `$output`;
	$cmd =~ s/\%/perc/;
	my $msg = " $tsIp is reachable";
	@jj = split( "\n", $cmd );
	my $limit = $#jj;
	my $found = 0;
	my $match = "packet loss";

	foreach ( my $i = 0 ; $i <= $limit ; $i++ ) {
		if ( $jj[$i] =~ /$match/i ) {
			$found = 0;
			if ( $jj[$i] =~ / 0perc/i ) {
				$found = 2;
				last;
			}
			$msg = " Error: $tsIp is not reachable =>" . $jj[$i];
			last;

		}
	}
  SWITCH_VERIFYTARGET: for ($found) {
		/0/ && do {
			$rc  = 0;
			$msg = "Error:$tsIp is not reachable";
			last;
		};
		/1/ && do {
			$rc = 0;
			last;
		};
		/2/ && do {
			$rc = 1;
			last;
		};
		die "verifyTarget: unrecognize error code $found \n";
	}
	return ( $rc, $msg );

}

#---------------------------------------------------------
# This routine is used to initialize the log feature
#---------------------------------------------------------
sub initLogger {
	my ( $profFile, $junk ) = @_;
	my $rc  = $PASS;
	my $msg = "Successfully Set Logger";

	#--------------------
	# initialize logger
	#---------------------
	my $temp       = $profFile->{scriptname};
	my $localLog   = $profFile->{logdir} . "/$temp.log";
	my $clobberLog = $profFile->{logdir} . "/$temp\_clobber.log";

	# layout: date-module + line mumber -(info,debug,warn,error,fatal)> message +  new line
	my $layout = Log::Log4perl::Layout::PatternLayout->new("%d--%F{1}:%L--%M--%p> %m%n");
	$profFile->{logger} = Log::Log4perl->get_logger();
	$profFile->{logger}->level("0");

	if ( $profFile->{screenOff} == 0 ) {
		my $screen = Log::Log4perl::Appender->new( "Log::Log4perl::Appender::Screen", stderr => 0 );
		$profFile->{logger}->add_appender($screen);
	}
	if ( $profFile->{logOff} == 0 ) {
		my $appender = Log::Log4perl::Appender->new(
			"Log::Log4perl::Appender::File",
			filename => $localLog,
			mode     => "append"
		);
		my $writer = Log::Log4perl::Appender->new(
			"Log::Log4perl::Appender::File",
			filename => $clobberLog,
			mode     => "clobber"
		);
		$appender->layout($layout);
		$profFile->{logger}->add_appender($appender);
		$profFile->{logger}->add_appender($writer);
	}
	$profFile->{logger}->info("--> Log initialized <--");
	return ( $rc, $msg );

}

#************************************************************
# This routine is used to increase the ipaddress/netmask
# or ipaddress alone
#************************************************************
sub ipIncr {
	my ( $profFile, $ipOrg, $incr ) = @_;
	my $log = $profFile->{logger};
	my ( $ip, $mask ) = split( '/', $ipOrg );
	my @add       = split( '\.', $ip );
	my $temp      = @add;
	my $mod       = 0;
	my $nextCount = 0;
	my $i;

	if ( defined $mask ) {
		$log->info(" Increment $ip -- mask= $mask -- IP fields=$temp") if ( $profFile->{debug} > 3 );
	} else {
		$log->info(" Increment $ip -- NO mask -- IP fields=$temp ") if ( $profFile->{debug} > 3 );
	}
	if ( $temp != 4 ) { return $ipOrg; }

	#    $log->info("Start IP(3) = $add[3]");
	$add[3] += $incr;
	for ( $i = 3 ; $i >= 0 ; $i-- ) {

		#	$log->info("IP($i) = $add[$i]");
		$add[$i] += $nextCount;
		if ( $add[$i] > 254 ) {
			$nextCount = 1;
			$add[$i] = $add[$i] % 255;
		} else {
			$nextCount = 0;
		}

		#	$log->info("MOD IP($i) = $add[$i]");
		if ( ( $add[$i] == 0 ) && ( $i == 3 ) ) {
			$add[$i]++;
		}
	}
	$ip = join( '.', @add );
	if ( defined $mask ) {
		$ip = join( '/', $ip, $mask );
	}
	return ($ip);
}

#************************************************************
# This routine is used to convert the number of bit to
# hex netmask
#************************************************************
sub netmask {
	my $maskNum = shift;
	my $count;
	my $mask  = 0;
	my $limit = 31;
	for ( $count = 0 ; $count < $maskNum ; $count++ ) {
		$mask = ( $mask | 0x1 ) << 1;
	}
	$limit = $limit - $maskNum;
	for ( $count = 0 ; $count < $limit ; $count++ ) {
		$mask = $mask << 1;
	}
	return ($mask);
}

#-------------------------------------------------------
# Set up Child Process
#--------------------------------------------------------
sub launchCmd {
	my ( $profFile, $testLog, $cmd, $tmo, $strTest ) = @_;
	my $rc         = $PASS;
	my $log        = $profFile->{logger};
	my $retry      = 1;
	my $localRetry = 1;
	my $wait       = 5;
	my $temp       = 0;
	my @buff;
	my $msg;
	my $exp = Expect->spawn($cmd);
	$exp->log_file( "$testLog", "w" );
	$exp->expect(
		$tmo,
		[
			timeout => sub {
				$rc  = $FAIL;                    #failed
				$msg = "Error: Timeout--$cmd";
				return ( $rc, $msg );
			  }
		],
		[ eof => sub { printf "EOF \n"; $rc = 1 } ],
	);
	$rc = $exp->exitstatus();
	$exp->log_file();
	$exp->soft_close();

	# start to check the error
	$temp = `grep $strTest $testLog | wc `;
	@buff = split( ' ', $temp );
	$log->info("BUFF = $buff[0], $buff[1], $buff[2] \n");
	if ( $buff[0] == 0 ) {
		$rc  = $PASS;
		$msg = "Successful to execute $cmd ";
	} else {
		$rc   = $FAIL;
		$temp = `grep $strTest $testLog `;
		$msg  = "Failed to execute $cmd --- $temp ";
	}
	return ( $rc, $msg );
}

#************************************************************
# Push all commands from data to command buffer
#************************************************************

sub popBuff {
	my ($profFile) = @_;
	my $buff       = \@{ $profFile->{commands} };
	my $fname      = $profFile->{filename};
	my $line;
	$fname = `ls $fname`;
	$fname =~ s/\n//;
	if ( !( -e $fname ) ) {
		print("ERROR: file $fname could not be found\n");
		exit 1;
	}
	open( FD, "<$fname" ) or die "Could not read $fname $!";
	while ( $line = <FD> ) {
		next if ( $line =~ /^\#.*/ );
		next if ( $line =~ /^\s*$/ );
		$line =~ s/\n//g;
		push( @{$buff}, $line );
	}
}

#--------------------------------
# This routine is used to send commands from the commands arrays entered
# via file system or command line
#--------------------------------
sub sendBatchCmd {
	my ($profFile) = @_;
	my $log        = $profFile->{logger};
	my $rc         = $PASS;
	my $resFD      = $profFile->{resultFN};
	my $current;
	my $cmds   = \@{ $profFile->{commands} };
	my $llimit = 0;
	my $subcmd;
	my $dutIp;
	my $result;
	my $stafproc;
	my $stafcmd;
	my $msg = "Execute all commands complete\n";
	$llimit = $#{$cmds};
	printf(" LIMIT = $llimit -- $cmds->[0]");

	# clean all expect buffer
	if ( @{$cmds} == 0 ) {
		$msg = "Command Buffer is Empty ";
		$log->info($msg);
		return ( $rc, $msg );
	}
	$profFile->{stafhandle} = STAF::STAFHandle->new("sendbatchcmd");
	if ( $profFile->{stafhandle}->{rc} != $STAF::kOk ) {
		$msg = "sendbatchCmd: Error registering with STAF, RC: $profFile->{stafhandle}->{rc}\n";
		$log->info($msg);
		return ( $FAIL, $msg );
	}
	print $resFD "Open HANDLE = $profFile->{stafhandle}->{handle} \n" if ( $profFile->{debug} > 3 );
	for ( $current = 0 ; $current <= $llimit ; $current++ ) {
		$subcmd = $cmds->[$current];
		$subcmd =~ s/\n//;
		$log->info("[$current]COMMAND = $subcmd ");    # if  ($profFile->{debug} > 3 );
		                                               #-----------------------------
		$dutIp    = $profFile->{dutIp};
		$stafcmd  = "START SHELL COMMAND " . STAF::WrapData($subcmd) . " RETURNSTDOUT STDERRTOSTDOUT WAIT";
		$stafproc = "process";
		print $resFD "\[$current\]$dutIp:$subcmd\n";
		( $rc, $msg ) = stafCmd( $profFile, $dutIp, $stafproc, $stafcmd );

		if ( $rc != $PASS ) {
			$log->error($msg);
		} else {
			$log->info($msg);
		}
		print $resFD "$msg";
	}
	$result = $profFile->{stafhandle}->unRegister();
	if ( $result != $STAF::kOk ) {
		$msg = "sendbatchcmd: Error unregistering with STAF, RC: $STAF::{RC}\n";
		$rc  = $FAIL;
	}
	print $resFD "CLose HANDLE = $profFile->{stafhandle}->{handle} \n" if ( $profFile->{debug} > 3 );
	return ( $rc, $msg );
}

#----------------------------------------------------------------------
# This subroutine is used the staf command to initiate STAF process command
#---------------------------------------------------------------------
sub stafCmd {
	my ( $profFile, $dutIp, $stafproc, $stafcmd ) = @_;
	my $handle = $profFile->{stafhandle};
	my $rc;
	my $log = $profFile->{logger};
	my $msg;
	print "stafCMD HANDLE = $handle->{handle} \n";    # if ( $profFile->{debug} > 3 );
	my $result = $handle->submit( $dutIp, $stafproc, $stafcmd );

	if ( $result->{rc} != $STAF::kOk ) {
		$msg = "Error submitting Handle( $handle->{handle}) -- $stafcmd request to $dutIp, RC: $STAF::RC\n";
		if ( length( $result->{result} ) != 0 ) {
			$msg .= "Additional error info: $result->{result}\n";
		}
		return ( $FAIL, $msg );
	}

	# Get process RC
	my $data = Dumper($result);

	#    print $data;
	#    print " $result->{resultObj}";
	#    exit 0;
	my $processRC = $result->{resultObj}->{rc};

	#    my $processRC = $result->{rc};
	# Verify that the rc is 0 for returning data for the Stdout file

	my $stdoutRC = $result->{resultObj}->{fileList}[0]{rc};

	if ( $stdoutRC != $STAF::kOk ) {
		$msg = "Error on retrieving process's stdout data.\n";

		#	$msg .= "Expected RC: 0\n";
		#	$msg .= "Received RC: $stdoutRC\n";
		$rc = $FAIL;
		retrun( $FAIL, $msg );
	}

	# Print the data in the stdout file created by the process

	my $stdoutData = $result->{resultObj}->{fileList}[0]{data};

	$msg = "\nProcess Stdout File Contains:\n";
	$msg .= "$stdoutData\n";

	# Verify that the process rc is 0

	if ( $processRC != $STAF::kOk ) {
		$msg .= "Process RC: $processRC\n";
		$msg .= "Expected Process RC: 0\n";
		return ( $FAIL, $msg );
	}

	return ( $PASS, $msg );
}

#----------------------------------------------------------------------
# This subroutine is used the staf command to initiate STAF process command
#---------------------------------------------------------------------
sub stafCmd3 {
	my ( $profFile, $dutIp, $stafproc, $stafcmd ) = @_;
	my $handle = $profFile->{stafhandle};
	my $rc;
	my $log = $profFile->{logger};
	my $msg;
	print "stafCMD HANDLE = $handle->{handle} \n";    # if ( $profFile->{debug} > 3 );
	my $result = $handle->submit( $dutIp, $stafproc, $stafcmd );

	if ( $result->{rc} != $STAF::kOk ) {
		$msg = "Error submitting Handle( $handle->{handle}) -- $stafcmd request to $dutIp, RC: $STAF::RC\n";
		if ( length( $result->{result} ) != 0 ) {
			$msg .= "Additional error info: $result->{result}\n";
		}
		return ( $FAIL, $msg );
	}

	# Get process RC
	#    my $data= Dumper($result);
	#    print $data;
	#    print " $result->{resultObj}";

	# Print the data in the stdout file created by the process

	my $stdoutData = $result->{resultObj};

	$msg = "\nProcess Stdout File Contains:\n";
	$msg .= "$stdoutData\n";

	return ( $PASS, $msg );
}

#-----------------------------------------------------------
# This routine is used to verify of the target is up
#-----------------------------------------------------------
sub verifyStaf {
	my ( $profFile, $dutIp ) = @_;
	my $cmd     = "ping";
	my $process = "ping";
	my $log     = $profFile->{logger};
	$log->info("target=$dutIp,process=$process ,cmd=$cmd");
	my $rc;
	my $result;
	my $msg    = "";
	my $handle = STAF::STAFHandle->new("verifyStaf");

	if ( $handle->{rc} != $STAF::kOk ) {
		$msg = "Error registering with STAF, RC: $handle->{rc}\n";
		$log->info($msg);
		return ( $FAIL, $msg );
	}
	$result = $handle->submit( "$dutIp", "$process", "$cmd" );
	if ( $result->{rc} != $STAF::kOk ) {
		$msg = "Error submitting Handle ($handle->{handle})- a $cmd request to $dutIp, RC: $STAF::RC\n";
		if ( length( $result->{result} ) != 0 ) {
			$msg .= "   Additional error info: $result->{result}\n";
		}
		$rc = $FAIL;
	} else {
		if ( length( $result->{result} ) != 0 ) {
			$msg .= "info:Handle ($handle->{handle}) $result->{result}\n";
		}
		$rc = $PASS;
	}
	$result = $handle->unRegister();
	if ( $result != $STAF::kOk ) {
		print "Error unregistering with STAF, RC: $STAF::{RC}\n";
		$rc = $FAIL;
	}

	#    $log->info($msg);
	return ( $rc, $msg );
}

#************************************************************
# Main Routine
#************************************************************
MAIN:
my $exp;
my $TRUE  = 1;
my $FALSE = 0;
my @userTemp;
my ( $x, $h );
my $option_h;
my $rc = 0;
my $msg;
my $key;
my $logdir;
my @commands = ();
my @org;
my $option_man = 0;
my $done       = 0;
my $count      = 1;
$rc = GetOptions(
	"x=s"    => \$userInput{debug},
	"help|h" => \$option_h,
	"man"    => \$option_man,
	"s"      => \$userInput{screenOff},
	"n"      => \$userInput{logOff},
	"d=s"    => \$userInput{dutIp},
	"l=s"    => \$userInput{logdir},
	"o=s"    => \$userInput{outputfile},
	"f=s"    => sub { $userInput{filename} = $_[1]; popBuff( \%userInput ); },
	"v=s"    => sub {
		if ( exists $userInput{commands}[0] ) { push( @{ $userInput{commands} }, $_[1] ); }
		else                                  { $userInput{commands}[0] = $_[1]; }
	},
);

#Using pod2usage to display Help or Man
pod2usage(1) if ($option_h);
pod2usage( -verbose => 2 ) if ($option_man);

#printf("--------------- Input Parameters  ---------------\n") if $userInput{debug} ;
printf("--------------- $scriptFn  Input Parameters  ---------------\n");
foreach $key ( keys %userInput ) {

	#    printf (" $key = $userInput{$key} :: " ) if $userInput{debug} ;
	printf(" $key = $userInput{$key} :: ");
}
my $limit = @{ $userInput{commands} };
$count = 0;
if ( $limit != 0 ) {
	print "\n--------($limit) shell commands will be executed -----\n";
	foreach my $line ( @{ $userInput{commands} } ) {
		print "\[$count\]$line \n";
		print "------------------ End ----------------- \n";
		$count++;
	}
}

#---------------------------------------------
# Initialize Logger
#---------------------------------------------
( $rc, $msg ) = initLogger( \%userInput, );
if ( $rc != 1 ) {
	printf("RC$rc $msg\n");
	exit 1;
}

#-------------------------------------
# Check Out Local Staf if it is up
#-------------------------------------
( $rc, $msg ) = verifyStaf( \%userInput, "localhost" );
if ( $rc == $FAIL ) {
	$userInput{logger}->error("$msg");
	exit 1;
} else {
	$userInput{logger}->info("$msg");
}

#-------------------------------------
# Check Out Local Staf if it is up
#-------------------------------------
( $rc, $msg ) = verifyStaf( \%userInput, $userInput{dutIp} );
if ( $rc == $FAIL ) {
	$userInput{logger}->error("$msg");
	exit 1;
} else {
	$userInput{logger}->info("$msg");
}

#-------------------------------------
# Set up output file
#-------------------------------------
my $outputfile = getBaseName( $userInput{outputfile} );
if ( $userInput{outputfile} =~ /$NOTDEFINED/ ) {
	$outputfile = "stafcmd_output.txt";
}
@org = split( '\.', $outputfile );
$outputfile = $userInput{logdir} . "/$outputfile";
while ( $done == 0 ) {
	if ( -e $outputfile ) {
		$outputfile = $userInput{logdir} . "/" . $org[0] . "_$count";
		$outputfile .= "\." . $org[1] if ( defined $org[1] );
		$count++;
		next;
	}
	$done = 1;
}
$userInput{logger}->info("Shell command output is saved to $outputfile");
open( FD, ">$outputfile" ) or die " could not create $outputfile";
$userInput{resultFN} = *FD;

#-------------------------------------
# Send bach command lists.
#-------------------------------------
( $rc, $msg ) = sendBatchCmd( \%userInput );
if ( $rc != $PASS ) {
	$userInput{logger}->info("\n=o=> Cli configuration failed : $msg \n");
	exit(1);
}
close FD;
if ( $rc == $FAIL ) {
	$userInput{logger}->error("==> Staf commands were failed to process ");
	exit 1;
}
$userInput{logger}->info("==> Staf commands were successfully executed ");
exit(0);
1;
__END__

=pod

=head1 NAME

stafcmd.pl - Send regular single shell or batch shell commands through STAF service. 

=head1 SYNOPSIS

=over 12

=item B<stafcmd.pl>
[B<-help|-h>]
[B<-man>]
[B<-f> I<shell command batch file>
[B<-d> I<target IP address >]
[B<-l> I<log file path>]
[B<-o> I<output file that contain the output of the shell commands>]
[B<-x> I<set debug level>]
[B<-v> I<VAR1=... > [-v I<VAR2=...> ...]]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-s>

Turn off screen ouput.

=item B<-n>

Turn off message log.

=item B<-f>

Specify the batch shell command.

=item B<-d>

Specify the target Ip address

=item B<-l >

Redirect stdout to the /path/stafcmd.log    

=item B<-x>

Specify the debug level. ( more debug messages for  higher number )

=item B<-v>
 
Command lines  ( e.g: -v "dir c:\\" -v "type c:\autoexec.bat" )

=back

=head1 DESCRIPTION

B<tbcfg.pl> allows user to configure a testbed harness through the pre-defined xml file.


=head1 EXAMPLES

1. The following command is used to display a windows directory and save all logs to /tmp directory and output of shell cmds to /tmp/stafcmd_output.txt
         perl stafcmd.pl -d 10.10.10.1 -v "dir c:\\" -l /tmp/

2. The following command is used to display a windows directory and save all logs to /tmp directory and output of shell cmds to /tmp/mytest.txt
         perl stafcmd.pl -d 10.10.10.1 -v "dir c:\\" -l /tmp/ -o mytest.txt


=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut

