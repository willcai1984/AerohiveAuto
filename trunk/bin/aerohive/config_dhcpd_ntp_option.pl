#!/usr/bin/perl -w
use strict;
use warnings;
use DBI;
use Pod::Usage;
use Data::Dumper;
use Getopt::Long;

my $space = 'dhcpd_ntp_setting';
my $man  = 0;
my $help = 0;
my $action = '';
my $jobid = ''; # who use this resource -- user
my $config = '';
my $debug = 0;

GetOptions(
	'help|?'    => \$help,
	'man'       => \$man,
    'action|a=s'  => \$action,
	'jobid|j=s'   => \$jobid,
	'config|c=s'  => \$config,
    'debug|d'     => \$debug,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

unless(defined($action) && ($action =~ m/^(config|restore)$/i)){
    warn "Need specify action: release|get\n";
    exit -1;
}
unless(defined($jobid)){
    warn "Need specify jobid\n";
    exit -1;
}

my $db     = 'awp';
my $host   = '10.155.40.241';
my $user   = 'awper';
my $passwd = 'aerohive';

my $dsn = "DBI:mysql:database=$db;host=$host;mysql_read_default_group=client";
my $dbh = DBI->connect( $dsn, $user, $passwd, { 'RaiseError' => 1 } );
if ( !$dbh ) {
	die "Can't connect to $dsn: $!";
}
print "Connect DB OK!\n" if $debug;

my $query = "SELECT * FROM AWP_CaseResource WHERE Space='$space'";
my $hash = $dbh->selectrow_hashref($query);
my @users = split(/,/, $hash->{'User'});
print Dumper(\@users) if $debug;
print Dumper($hash) if $debug;

#Status 0 is idle , 1 is busy
#release resource
if($action eq 'restore'){
    @users = grep { $_ ne $jobid } @users;
    if(@users){
        my $users_str = join(',', @users);
        $query = "UPDATE AWP_CaseResource SET User='$users_str'
                  WHERE Space='$space'";
        $dbh->do($query) or die "Cannot release resource(remove user), $@";
        print "Remove user $jobid from the user list, Release resource OK\n" if $debug;
        print "NOCHANGE\n";
        exit 0;
    }
    else{
        $query = "UPDATE AWP_CaseResource SET Status=0,Value='',User=''
                  WHERE Space='$space'";
        $dbh->do($query) or die "Cannot release resource, $@";
        print "Release resource OK\n" if $debug;
        print "RESET\n";
        exit 0;
    }
}
#get resource
if($action eq 'config'){
    if($hash->{'Status'} == 0){
        if(defined($config)){
            $query = "UPDATE AWP_CaseResource SET Value='$config', User='$jobid',
                      Status=1 WHERE Space='$space'";
            $dbh->do($query) or die "Cannot get resource, $@";
            print "SET\n";
            exit 0;
        }
        else{
            warn "Need specify a config\n";
            exit -1;
        }
    }
    elsif($hash->{'Status'} == 1){
        if($hash->{'Value'} eq $config){
            $jobid = $hash->{'User'} . ",$jobid";
            $query = "UPDATE AWP_CaseResource SET User='$jobid'
                      WHERE Space='$space'";
            $dbh->do($query) or die "Cannot add user, $@";
            print "NOCHANGE\n";
            exit 0;
        }
        else{
            warn "Resource is busy now, get resource failed\n";
            exit -1;
        }
    }
    else{
        print "Resource status error\n";
        exit -1;
    }
}


END{
    $dbh->disconnect();
}

__END__

=head1 NAME

config_dhcpd_ntp_option.pl - Get and release resource of pub DHCP server's ntp option.

=head1 SYNOPSIS
    get resource
        config_dhcpd_ntp_option.pl --action "get" --jobid "20130110-7029" --config "192.168.10.202"
        config_dhcpd_ntp_option.pl -a "get" -j "20130110-7029" -c "192.168.10.202"
    Release resource
        config_dhcpd_ntp_option.pl --action "release" --jobid "20130110-7029"
        config_dhcpd_ntp_option.pl -a "release" -j "20130110-7029"
        
=head1 OPTIONS

=over 8

=item B<-help>
Print a brief help message and exits.

=item B<-man>
Prints the manual page and exits.

=item B<--action|-a>
Specify the action among "release" and "get"

=item B<--jobid|-j>
Specify which job is using the resource

=item B<--config|-c>
Specify the config of ntp option

=back

=head1 DESCRIPTION

B<This program> will get and release public DHCP server's ntp option resource by maintain a
resource status table in MySQL database.

=cut
