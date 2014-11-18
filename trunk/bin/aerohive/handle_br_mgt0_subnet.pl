#!/usr/bin/perl -w
use strict;

use DBI;
use Pod::Usage;
use Getopt::Long;

my $man  = 0;
my $help = 0;
my $get  = 0;
my $rid  = 0;
my $jobid = 0;
my $runUser = 0;

GetOptions(
	'help|?'      => \$help,
	'man'         => \$man,
	'get|g'       => \$get,
	'release|r=i' => \$rid,
	'jobid|j=s'   => \$jobid,
	'user|u=s'   => \$runUser,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

my $db     = 'awp';
my $host   = '10.155.40.241';
my $user   = 'awper';
my $passwd = 'aerohive';

my $dsn = "DBI:mysql:database=$db;host=$host;mysql_read_default_group=client";
my $dbh = DBI->connect( $dsn, $user, $passwd, { 'RaiseError' => 1 } );
if ( !$dbh ) {
	die "Can't connect to $dsn: $!";
}

#print "Connect DB OK!\n";

my $query = '';
my $sth;

#judge no any parameters
if (!$rid && !$get) {
	pod2usage(1);
	exit -1
}

#release resource by resourceid
if ($rid) {
	$dbh->do(
		"UPDATE AWP_CaseResource SET Status=3,JobID='',user=''
              WHERE Space='br.mgt0.subnet' AND value='$rid'"
	) or die "Cannot release resource for $rid\n";

	$dbh->disconnect;
	print "resource[$rid] was released\n";
	exit 0;
}

#get resource and return resource id (rid)
if ($get) {
	$sth = $dbh->prepare(
		"SELECT Value FROM AWP_CaseResource
                          WHERE Space='br.mgt0.subnet' AND Status=3 LIMIT 1"
	);
	$sth->execute;
	my @row = $sth->fetchrow_array;
	my $value = shift @row or die "Cannot get any resource\n";
	
	$dbh->do(
		"UPDATE AWP_CaseResource SET Status=2,JobID = '$jobid',User='$runUser'
              WHERE Space='br.mgt0.subnet' and value='$value'"
	) or die "Cannot change status for $value\n";
	$sth->finish;
	$dbh->disconnect;
	print "$value\n";
	exit 0;
}

$dbh->disconnect;
exit -1;

__END__

=head1 NAME

handle_br_mgt0_subnet.pl - Get and release resource of br mgt0 subnet

=head1 SYNOPSIS

    get resource
        handle_br_mgt0_subnet.pl --get
        handle_br_mgt0_subnet.pl -g
    Release resource
        handle_br_mgt0_subnet.pl --release 1
        handle_br_mgt0_subnet.pl -r 1
    #First release and then get    
    #    handle_br_mgt0_subnet.pl -r 1 -g
    #    handle_br_mgt0_subnet.pl -g -r 1
	
=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<--get|-g>

Get a resource and return the resource id

=item B<--jobid $jobid|-j $jobid>
Get a resource set a jobid 

=item B<--user $rid|-u $user>
Get a resource set a user 

=item B<--release $rid|-r $rid>

Release the resource via resource id

=back

=head1 DESCRIPTION

B<This program> will get and release br's mgt0 subnet resource by maintain a
resource status table in MySQL database.

=cut
