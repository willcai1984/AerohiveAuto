#!/usr/bin/perl -w
#-------------------------------------------------------------------
# Please report bug to hcheng@aerohive.com
#--------------------------------------------------------------------

use strict;
use Pod::Usage;
use Getopt::Long;
use Net::SSH::Expect;

my $host   = '10.155.40.224';
my $user   = 'auto2';
my $passwd = 'aerohive';

my $man  = 0;
my $help = 0;
my $tb   = '';
my $bpc  = 0;
my $ap   = 0;
my $vlan = '';

GetOptions(
	'h|?|help' => \$help,
	'man'      => \$man,
	'tb|t=s'   => \$tb,
	'bpc|b=i'  => \$bpc,
	'ap|a=i'   => \$ap,
	'vlan|v=s' => \$vlan,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

#print "$bpc\n$ap\n$vlan\n";
my $network_label = "$tb-ap$ap-$vlan";
my $tmp           = $tb;
$tmp =~ s/hz//i;

my $config_file = '';
if ( $bpc == 1 ) {
	$config_file = "/vmfs/volumes/4ef49228-56091c2a-2d26-782bcb5db4c3/$tmp-bpc$bpc\_1/$tmp-bpc$bpc\_1.vmx";
} else {
	$config_file = "/vmfs/volumes/4ef49228-56091c2a-2d26-782bcb5db4c3/$tmp-bpc$bpc/$tmp-bpc$bpc.vmx";
}

my $ssh = Net::SSH::Expect->new(
	host     => $host,
	password => $user,
	user     => $passwd,

	#raw_pty => 1
);
$ssh->login();
my $cmd    = "sed -i \'s/^ethernet1.networkName = \".*\"/ethernet1.networkName = \"$network_label\"/\' $config_file";
my $return = $ssh->exec($cmd);
print "$return\n";

#power on bpc
print `vmware-cmd --server $host --username $user --password $passwd $config_file start`;
print "sleep 60s to wait the VM power on\n";
sleep 60;

__END__

=head1 NAME

bpc_init.pl - Use to change the network label of bpc and power on it

=head1 SYNOPSIS

    bpc_init.pl [options]
    Options:
    -help            brief help message
    -man             full documentation
    --tb|-t          tb name 
    --bpc|-b         physical id of bpc
    --ap|-a          physical id of bpc     
    --vlan|-v        vlan tag(one of "vlan1", "vlan2", "vlan3", "none")
    
=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

=cut
