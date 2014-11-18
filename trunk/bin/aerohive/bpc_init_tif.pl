#!/usr/bin/perl -w
#--------------------------------------------------------------------
# Please report bug to hcheng@aerohive.com
#--------------------------------------------------------------------
use strict;
use Data::Dumper;
use VMware::VIRuntime;
use VMware::VILib;

#as our DNS server(10.15.40.233) can not do reverse lookup, so we need to store
#hostname of servers, like a config.
my %hostname = (
	'10.155.40.221' => 'hz-vm-server-1.qaauto.aerohive.com',
	'10.155.40.222' => 'hz-vm-server-2.qaauto.aerohive.com',
	'10.155.40.223' => 'hz-vm-server-3.qaauto.aerohive.com',
	'10.155.40.224' => 'hz-vm-server-4.qaauto.aerohive.com',
	'10.155.40.225' => 'hz-vm-server-5.qaauto.aerohive.com',
	'10.155.41.226' => 'hz-vm-server-6.qaauto.aerohive.com',
	'10.155.41.227' => 'hz-vm-server-7.qaauto.aerohive.com',
	'10.155.40.218' => 'hz-vm-server-8.qaauto.aerohive.com',
	'10.155.40.219' => 'hz-vm-server-9.qaauto.aerohive.com',
);

#Network label is a name on GUI, which is actually Port Group in VMware.
my %opts = (
	'vmname' => {
		type     => "=s",
		help     => "The name of the virtual machine",
		required => 1,
	},
	'vnic' => {
		type     => "=s",
		help     => "vNIC Adapter # (e.g. 1,2,3,etc)",
		required => 1,
	},
	'netlabel' => {
		type     => "=s",
		help     => "Portgroup to add",
		required => 1,
	},
);

# validate options, and connect to the server
Opts::add_options(%opts);
Opts::parse();
Opts::validate();
Util::connect();

my $vnic_device;
my $vmname    = Opts::get_option('vmname');
my $vnic      = Opts::get_option('vnic');
my $portgroup = Opts::get_option('netlabel');
my $server    = Opts::get_option('server');
my $vnic_name = '';
my $network;

print "Server: $server\n",
      "Virtual Machine: $vmname\n",
	  "Virtual NIC: $vnic\n",
	  "Network Label: $portgroup\n";

my $vm_view = Vim::find_entity_view( view_type => 'VirtualMachine', filter => { 'name' => $vmname } );

#print Dumper($vm_view);
my $host_view = Vim::find_entity_view(
	view_type => 'HostSystem',
	filter    => { 'name' => $hostname{$server} },
);

#print Dumper(\$host_view);
my $network_list = Vim::get_views( mo_ref_array => $host_view->network );

#print Dumper($network_list);
foreach (@$network_list) {

	#print "go in foreach\n";
	if ( $portgroup eq $_->name ) {
		print "find network\n";
		$network = $_;

		#print Dumper($network);
		last;
	}
}

#Find the vNIC
if ($vm_view) {
	my $config_spec_operation = VirtualDeviceConfigSpecOperation->new('edit');
	my $devices               = $vm_view->config->hardware->device;
	$vnic_name = "Network adapter $vnic";
	foreach my $device (@$devices) {
		if ( $device->deviceInfo->label eq $vnic_name ) {
			$vnic_device = $device;
		}
	}

	if ($vnic_device) {
		$vnic_device->deviceInfo->summary($portgroup);

		#my $backing = new VirtualEthernetCardNetworkBackingInfo(deviceName => $portgroup, useAutoDetect => 1);
		my $backing = new VirtualEthernetCardNetworkBackingInfo( deviceName => $portgroup, network => $network );
		$vnic_device->backing($backing);
		my $vm_dev_spec = VirtualDeviceConfigSpec->new( device => $vnic_device, operation => $config_spec_operation );
		my $vmPortgroupChangespec = VirtualMachineConfigSpec->new( deviceChange => [$vm_dev_spec] );
		eval { $vm_view->ReconfigVM( spec => $vmPortgroupChangespec ); };
		if ($@) {
			print "Reconfiguration of portgroup \"$portgroup\" failed.\n $@";
		} else {
			$vm_view->update_view_data();
			print "Reconfiguration of portgroup \"$portgroup\" successful for \"$vmname\".\n";
		}
	} else {
		print "Unable to find $vnic_name\n";
	}
} else {
	Util::trace( 0, "Unable to locate $vmname!\n" );
	exit 0;
}

Util::disconnect();

sub getNetwork {
	my $host_view = Vim::find_entity_view(
		view_type => 'HostSystem',
		filter    => { 'name' => $vmname },
	);
	my $network_list = Vim::get_views( mo_ref_array => $host_view->network );
	foreach (@$network_list) {
		if ( $vnic_name eq $_->name ) {
			return $_;
		}
	}
	print "can not get network\n";
}
