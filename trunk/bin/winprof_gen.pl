#!/usr/bin/perl -w
#-------------------------------------------------------------------
# Name: Joe Nguyen
# Description:
#---------------- 
#   This script is used to change the SSID header of a given xml wifi windows 
# profile file
#--------------------------------------------------------------------
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
#use Net::LDAP;
use POSIX ":sys_wait_h";
#use IO::Handle;
use POSIX ':signal_h';

#default timeout for each command
my $CMD_TMO = 60; 
my $SAVE_TBL = 1;
my $DISPLAY_ALL="display_all";
my $NOTREQ = "not_required";
my $REQ = "required";
#-----<<<----------------
my $PREFIXJOB="job";
my $NOTDEFINED= "not_defined";
my $ON=1;
my $OFF=0;
my $PASS=1;
my $FAIL=0;
my $verbose = 0;
my $NOFUNCTION="none";
my @junk = split( /\//, $0);
@junk = split('\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my $OUTPUTLOG_SIZE=40 * 1024;


my %userInput = (
    "debug" => "0",
    "logdir"=>"./",
    "scriptname"=>$scriptFn,
    "filename"=>$NOTDEFINED,
    "outputfile"=>$NOTDEFINED,
    "logger"=>"",
    "screenOff"=>0,
    "logOff"=>0,
    "ssid"=>$NOTDEFINED,
    );
#-----------------------------------------------------------
# This routine is used to get the base name 
#-----------------------------------------------------------

sub getBaseName {
    my ($path,$junk) = @_;
    my @t1;
    @t1=split("/",$path );
    $junk = $t1[$#t1];
    return ($junk);
}

#---------------------------------------------------------
# This routine is used to initialize the log feature
#---------------------------------------------------------
sub initLogger {
    my ( $profFile, $junk) = @_;
    my $rc = $PASS;
    my $msg ="Successfully Set Logger";
    #--------------------
    # initialize logger
    #---------------------
    my $temp = $profFile->{scriptname};
    my $localLog = $profFile->{logdir}."/$temp.log";
    my $clobberLog = $profFile->{logdir}."/$temp\_clobber.log";
    if ( -e $localLog ) {
	$temp = `rm -f $localLog`;
    }
    if ( -e $clobberLog ) {
	$temp = `rm -f $clobberLog`;
    }
    # layout: date-module + line mumber -(info,debug,warn,error,fatal)> message +  new line 
    my $layout = Log::Log4perl::Layout::PatternLayout->new("%d--%F{1}:%L--%M--%p> %m%n");
    my $gName = "initLogger";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }

    $profFile->{logger}= Log::Log4perl->get_logger();
    $profFile->{logger}->level("0");

    if ( $profFile->{screenOff} == 0 ) {
	my $screen = Log::Log4perl::Appender->new("Log::Log4perl::Appender::Screen",
						  stderr => 0);	
	$profFile->{logger}->add_appender($screen);
    }
    if ( $profFile->{logOff} == 0 ) {
	my $appender = Log::Log4perl::Appender->new("Log::Log4perl::Appender::File",
						    filename => $localLog,
						    mode => "append");
	my $writer = Log::Log4perl::Appender->new("Log::Log4perl::Appender::File",
						  filename => $clobberLog,
						  mode => "clobber");
	$appender->layout($layout);	
	$profFile->{logger}->add_appender($appender);
	$profFile->{logger}->add_appender($writer);
    }
    $profFile->{logger}->info("--> Log initialized <--");
    return($rc,$msg);

}

#************************************************************
# Generate new profile by using xml module
#************************************************************
sub generateProfile2 {
    my ($profFile,$junk)=@_;
    my $rc=$PASS;
    my $ssid=$profFile->{ssid};
    my ($ssidHex,$c);
    my $xml = new XML::Simple;
    my $log = $profFile->{logger};
    my $dirName = $profFile->{logdir};
    my $outputFile = $profFile->{outputfile};
    my $inputFile = $profFile->{filename};
    my @buff;
    my $data;
    my ($result,$temp);
    $inputFile = `ls $inputFile`;
    $inputFile =~ s/\n//;
    printf " file = $inputFile ";
    my  $msg="Display: $inputFile";
    if ( $inputFile =~ /No such/ ) {
	return ( $FAIL, $inputFile );
    }
   
    if ( $profFile->{debug} < 5 ) {
	eval { $data = $xml->XMLin("$inputFile")};
    } else {
	$data = $xml->XMLin("$inputFile");
    }
    if ( !defined $data) {
	$msg =`xmllint $inputFile`;
	return($FAIL,$msg);
    }
    $temp = Dumper($data);
    $log->info($temp) if ( $profFile->{debug} > 3 );
    #convert ssid to hex string
    @buff=unpack('C*', $ssid);
    $ssidHex = '';
    foreach my $c (@buff) {
	$ssidHex .= sprintf ("%lx", $c);
    }
    #Replace with new SSID 
    $data->{SSIDConfig}{SSID}{name}=$ssid;
    $data->{SSIDConfig}{SSID}{hex}=$ssidHex;
    $data->{name}=$ssid;
    my $output=$xml->XMLout($data);
    # Save to new output file
    open(OUTFD,">$outputFile") or die " could not create $outputFile ";
    print OUTFD $output;
    close OUTFD;
    return ( $PASS,$msg);

}
#************************************************************
# Generate new profile by using xml module
#************************************************************
sub generateProfile {
    my ($profFile,$junk)=@_;
    my $rc=$PASS;
    my $ssid=$profFile->{ssid};
    my ($ssidHex,$c);
    my $xml = new XML::Simple;
    my $log = $profFile->{logger};
    my $dirName = $profFile->{logdir};
    my $outputFile = $profFile->{outputfile};
    my $inputFile = $profFile->{filename};
    my @buff;
    my $line;
    my $data;
    my $temp;
    $inputFile = `ls $inputFile`;
    $inputFile =~ s/\n//;
    $log->info( " Parsing file = $inputFile ");
    my  $msg="Display: $inputFile";
    if ( $inputFile =~ /No such/ ) {
	return ( $FAIL, $inputFile );
    }

    #convert ssid to hex string
    @buff=unpack('C*', $ssid);
    $ssidHex = '';
    foreach my $c (@buff) {
	$ssidHex .= sprintf ("%lx", $c);
    }
    #Replace with new SSID 
    open (INFD,"<$inputFile") or die " could not read $inputFile ";
    open(OUTFD,">$outputFile") or die " could not create $outputFile ";
    my $startParsing =0;
    while ( ($line =<INFD>) ) { 
	if ( $startParsing == 0 ) {
	    next if ( $line !~ /\<\?xml version/ );
	    $startParsing =1;
	}

	if ( $line =~ /name\>/) {
	    $line="\t\t<name>$ssid</name>\n";
	}
	if ( $line =~ /hex\>/) {
	    $line="\t\t<hex>$ssidHex</hex>\n";
	}
	# Save to new output file	
	print OUTFD $line;
    }
    close OUTFD;
    close INFD;
    return ( $PASS,$msg);
}





#************************************************************
# Main Routine
#************************************************************
MAIN:
my $exp;
my $TRUE=1;
my $FALSE=0;
my @userTemp;
my ($x,$h);
my $option_h;
my $rc =0;
my $msg;
my $key;
my $logdir;
my $globalRc = $PASS;
my $option_man = 0;
my $jobid =0 ;
my $temp;
#---------------------------------------------
# Initialize Logger 
#---------------------------------------------


$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man, 
		  "l=s"=>sub {  $userInput{logdir} = $_[1]; $logdir = $_[1]},
		  "f=s"=>\$userInput{filename},
		  "o=s"=>\$userInput{outputfile},
		  "s=s"=>\$userInput{ssid},
		  "v=s"=>sub { if ( exists $userInput{commands}[0] ) { push (@{$userInput{commands}},$_[1]); } else {$userInput{commands}[0]=$_[1]; } } ,
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
($rc,$msg) = initLogger(\%userInput, 0);
if ( $rc != 1) {
    printf ("RC$rc $msg\n");
    exit 1;
} 
if  ( $userInput{ssid} =~ /$NOTDEFINED/) {
    $userInput{logger}->info("Error: please enter SSID");
    exit 1;
}
if ( $userInput{filename} =~ /$NOTDEFINED/){

    $userInput{logger}->info("Error: please enter filename");
    exit 1;
}

if ( !(-e $userInput{filename}) ) {
    $userInput{logger}->info("Error: filename $userInput{filename} is NOT found ");
    exit 1;
}

#-------------------------------------
# Set up output file 
#-------------------------------------
my $outputfile = getBaseName($userInput { outputfile});
if ( $userInput{outputfile} =~ /$NOTDEFINED/ ) {
    $outputfile = "winprof_gen_output.xml"; 
} 
$outputfile = $userInput{logdir}."/$outputfile";
$userInput{outputfile}= $outputfile;
$userInput{logger}->info("New XML file is saved to $outputfile");

($rc,$msg) = generateProfile (\%userInput);

exit (0);
1;
__END__

=pod

=head1 NAME

winprof_gen.pl - Used to create an output xml file with new header ssid from a given wifi windows profile xml file and 

=head1 SYNOPSIS

=over

=item B<xmlreader.pl>
[B<-help|-h>]
[B<-man>]
[B<-o> I<output file >]
[B<-s> I<ssid >]
[B<-f> I< XML file>]
[B<-l> I<log file directory>]

=back

=head1 OPTIONS AND ARGUMENTS

=over


=item B<-f>

Input windows wifi profile XML File 

=item B<-f>

New output windows wifi profile XML File with new ssid 

=item B<-l >

Redirect stdout to the /path/winprof_gen.log

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)


=back


=head1 EXAMPLES

=over

1. This command is used to read in a  xml file and created a new output.xml
    xmlreader.pl -f winprofile.xml -o wifi_test.xml -l /tmp -s tb1-AP5020N-1

=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut

