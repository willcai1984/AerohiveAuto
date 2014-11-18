#!/usr/bin/perl -w

use strict;
use DBI;
use Getopt::Long;

my $help = 0;
my $man = 0;
#set default value for each variable
my $jobid = '';
my $var = '';

GetOptions(
    'help|?'    => \$help,
	man         => \$man,
    'jobid=s'   => \$jobid,
    'var=s'     => \$var,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

die "Error, need specify JobID!\n" unless $jobid;
die "Error, need specify variables!\n" unless $var;

my $db_host = '10.155.40.200';
my $db_name = 'performance';
my $db_user = 'perf';
my $db_passwd = 'aerohive';

my $dsn = "DBI:mysql:database=$db_name;host=$db_host;mysql_read_default_group=client";
my $dbh = DBI->connect($dsn, $db_user, $db_passwd,
                       {'RaiseError' => 1}
                       );
if(!$dbh){
    die "Can't connect to $dsn: $!";
}
print "Connect DB OK!\n";

my $insert = "INSERT INTO Job (JobID, JobParameter) VALUES ('$jobid', '$var')";
$dbh->do($insert) or die $dbh->errstr;
print "insert OK!\n";
$dbh->disconnect();