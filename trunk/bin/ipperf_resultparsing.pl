#!/usr/bin/perl -w
#--------------------------------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to generate testcase extracted from xml testcase description and reindex the testcase step 
#
#-------------------------------------------------------
use strict;
use warnings;
use diagnostics;
use Expect;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use Log::Log4perl;
use XML::Simple;
use Data::Dumper;


my $PASS=1;
my $FAIL=0;
my $NOPATH="noPathGiven";
my $NOTDEFINED="notdefined";
my @junk = split( /\//, $0);
@junk = split( '\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my %userInput = ( "debug"=>0,
		  "logdir"=>$NOTDEFINED,
		  "filename"=>$NOTDEFINED,		  
		  "outputfile"=>$NOTDEFINED,
		  "logger"=>$NOTDEFINED,
		  "screenOff"=> 0,
		  "logOff"=> 1,
		  "summary"=>1,
		  "scriptname"=>$scriptFn,

    );
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

#************************************************************

sub getBaseName {
    my ($path,$junk)=@_;
    my @temp = split('/',$path);
    $junk = $temp[$#temp];
    return $junk;
}
sub generateOUTPUTS {
    my ($profFile)=@_;
    my $inputFile= $profFile->{filename};
    my $log = $profFile->{logger};
    my($directory, $filename) = $inputFile =~ m/(.*\/)(.*)$/;
    my @buff ;
    @buff = split ('\.',$filename);
        
    if ( defined $filename ) {
	$filename = $buff[0];
    } else {
	$filename = $inputFile;
    }
    if ( ! (defined $directory ) ) {
	$directory="./";
    }
    $log->info( "$directory"); 
    $log->info( "F2=$filename");

    
    $filename= $buff[0];
    my $index;
    my $FN = $profFile->{resultFN};

    if ( $filename =~ /\d/ ) {
	$index = index($filename,'\d');
	$filename = substr ( $filename,0,$index);
    } 
    $inputFile=$directory."/".$filename."*";
    my $rc=$PASS;
    my $msg;
    my @temp;
    my $line;
    my $count=1;
    $log->info( "base input file =  $inputFile D=$directory, F=$filename");

    my $cmd ="ls -1X $inputFile";
    $line=`$cmd`;
    $log->info ("cmd\n$line\n") if ( $profFile->{debug} > 1 );
    @buff=split("\n",$line);
    #get Header
    foreach $line ( @buff ) {
	$line=~ s/\n//;
	($rc,$msg)= getHeader($profFile,$line);
	if ( $rc == $PASS) {
	    $log->info ("Found: $msg") if ($profFile->{debug} > 3 );
	    print $FN $msg;
	    last;
	}
    }
# for future enhancement
    if ($profFile->{summary} == 1 )  {
	$msg ="Index;Interval;Transfer;bandwitdh\n";
	print $FN $msg;
    } else {
	$msg ="Index;Interval;Transfer;bandwitdh\n";
	print $FN $msg;
    }

    foreach $line ( @buff ) {
	$line=~ s/\n//g;
	($rc,$msg)= getSummary($profFile,$line);
	$log->info ("SUM result: $line -- $msg") if ($profFile->{debug} > 3 );
	$line = $line.$msg;
	print $FN "$line\n" ;
    }
    $msg = "Succefully generate test result to $profFile->{outputfile}";
    return($PASS,$msg);
}
#************************************************************
#  This routine is used to reindex xml file  
#************************************************************
sub getHeader {
    my ($profFile,$inputFile,$stepIncr)=@_;
    my $rc=$PASS;
    my $msg="Description:\n";
    my $FN=$profFile->{resultFN};
    my @buff;
    my $line;
    my $count =0;
    my $log = $profFile->{logger};
    open(INPUT, "< $inputFile" ) or die " Could not read $inputFile";
    @buff=<INPUT>;
    close INPUT;
    my $found = 1;
    for ( $count=0 ; $count <= $#buff; $count ++ ) {
	$line = $buff[$count];
	next if ($line =~ /^\s*$/ );
	next if (( $line !~ /Client connecting/ ) && ( $line !~ /TCP window/ ) && ( $line !~ /Server listening/ ) && ( $line !~ /iperf/ ) );

	$found ++;
	$msg .= $line;
    }
    return ($PASS,$msg) if ( $found > 4) ;
    return ($FAIL,"Error:could not find IPERF Description header ");
}
#************************************************************
#  This routine is used to reindex xml file  
#************************************************************
sub getSummary {
    my ($profFile,$inputFile,$stepIncr)=@_;
    my $rc=$FAIL;
    my $msg="Get $inputFile";
    my $FN=$profFile->{resultFN};
    my @buff;
    my $line;
    my @temp;
    my $index;
    my $t1="";
    my $count =0;
    my $log = $profFile->{logger};
    open(INPUT, "< $inputFile" ) or die " Could not read $inputFile";
    @buff=<INPUT>;
    close INPUT;
    my $result=";0;0;0;";
    #[SUM]  0.0-34.6 sec  11.4 MBytes  2.77 Mbits/sec
    for ( $count=0 ; $count <= $#buff; $count ++ ) {
	$line = $buff[$count];
	$line =~ s/\n//;
	next if ($line =~ /^\s*$/ );
	next if ( $line !~ /\[SUM\]/);
	@temp= split('\s\s',$line);
	for ($index  = 1; $index <=$#temp ; $index ++) {
	    $t1 .= ";".$temp[$index];
	}
	$result = $t1;
	$t1 = "";
    }
    return($rc,$result);
}


#************************************************************
# Main Routine
#************************************************************
MAIN:
my @buff;
my ($x,$h);
my $option_h;
my $option_man = 0;
my $rc = 0;
my $msg;
my $key;
my $current;
my $limit;
my ($index,$temp);
my $example = "Example: ";
my $usage="Usage: generate testcase documents.txt  \n\t\tgenerate_tcdocs.pl -f <filename> -o <optional filename> -l <directory where new files will be saved>";
my @commands = ();

$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man,
		  "l=s"=>\$userInput{logdir},		  
		  "f=s"=>\$userInput{filename},		  
		  "o=s"=>\$userInput{outputfile},		  
		  "d"=>\$userInput{display},
		  "z"=>sub { $userInput{logOff} = 0 },
		  "w"=>\$userInput{wildcard},
		  "v=s"=>sub { if ( exists $commands[0] ) { push (@commands,$_[1]); } else {$commands[0]=$_[1]; } } ,
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
my $dir = $userInput{logdir};
if ( $dir =~ $NOTDEFINED ) {
    $dir=`pwd`;
    $dir=~ s/\n//;
    $userInput{logdir} = $dir;
    printf ( "DIR = $dir \n");
}
($rc,$msg) = initLogger(\%userInput, 0);
if ( $rc != 1) {
    printf ("RC$rc $msg\n");
    exit 1;
} 
my $fn = $userInput{filename};


if ( ($fn =~ /$NOTDEFINED/ ) ) {

    $userInput{logger}->info( "Error = please fill in the missing operand = filename($fn)");
    pod2usage(1);
    exit 1;
}

my $outputfile = $userInput{outputfile};


if ( $outputfile =~ /$NOTDEFINED/ ) {
    $temp = $userInput{scriptname};
    @buff=split('\.',$temp);
    $outputfile = $dir."/$buff[0]\.txt";
    $userInput{outputfile} = $outputfile;
} else {
    $outputfile = $dir."/".$outputfile;
    $userInput{outputfile} = $outputfile;
}
@buff = split ('/',$fn);
$temp = getBaseName($fn);
$userInput{logger}->info( "Input file = $temp -- $fn");

open(FD,">$outputfile") or die " could not create $outputfile";

$userInput{resultFN}=*FD;
($rc,$msg)=generateOUTPUTS(\%userInput);

close FD;
$userInput{logger}->info($msg);
if ($userInput{display}) {
    $msg = `cat $userInput{outputfile}`;
    $userInput{logger}->info($msg);
}
exit 0 if ($rc == $PASS ) ;
exit 1;
1;

=head1 NAME

ipperf_resultparsing.pl - Used to collect all iperf result file with the same base name and save it to a csv file 

=head1 SYNOPSIS

=over

=item B<ipperf_resultparsing.pl>
[B<-help|-h>]
[B<-man>]
[B<-f> I< iperf based filename>]
[B<-o> I< output csv filename>]
[B<-l> I<log file directory>]


=back

=head1 OPTIONS AND ARGUMENTS

=over


=item B<-l >

Redirect stdout to the /path/xmlxxx.log


=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)

=item B<-n>

No display of the execution section

=item B<-r>

Reindex all steps

=item B<-f>

Based ipperf input file

=item B<-o>

Output file



=back


=head1 EXAMPLES

=over

1. This command is used to generate a csv file from  a based file name and  
    output was saved to test123.csv
    ipperf_resultparsing.pl -f ipperf_client.log -o test123.csv



=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
