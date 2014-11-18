#!/usr/bin/perl -w
use strict;
use Expect;
use Data::Dumper;
use JSON::Parse qw(parse_json valid_json);

our %returnCode = (
    0 => 'Pass',
    1 => 'Cannot get ssid',
    2 => 'Cannot get interface name (ifname)',
    3 => 'Auth negative test fail',
    4 => 'DHCP negative test fail',
    5 => 'Cannot start wpa_supplicant daemon',
    6 => 'Cannot up network interface',
    7 => 'Cannot complete auth process',
    8 => 'Cannot get ip from DHCP',
    9 => 'Cannot ping through DHCP server',
    253 => 'Get cert files from tftp server failed',
    254 => 'JSON object is invalid',
    255 => 'No return code',
);

our $json = shift @ARGV;
our $perlObj;
our $certs_server = '10.155.44.237'; #this is the default certs server
our $IP;
our $MAC;
our $DHCP_SERVER;
our @DNS_SERVERS;

#my $json = '{
#    "ssid" : "hzaptb5-ap350-1-6667",
#    "bind" : "wifi0",
#    "crypto" : "WPA-EAP"
#}';

# has the attribute and not NULL
sub run {
    my $cmd = shift;
    print "@@ $cmd @@\n";
    sleep 1;
    return `$cmd`;
}

sub has {
    my $obj = shift;
    my $name = shift;
    return (defined($obj->{$name}) && $obj->{$name} ne '');
}

sub is_interface_up {
    my $ifname = shift;
    
    #my @ifconfig = `ifconfig`;
    my @ifconfig = run("ifconfig");
    foreach my $line (@ifconfig){
        return 1 if $line =~ m/^$ifname/;
    }
    
    return 0;
}

sub is_connect_complete {
    my $ssid = shift;
    
    my $check_max_times = 6;
    my $check_interval = 10;
    for(my $i = 1; $i <= $check_max_times; $i++) {
        my @arr = run("wpa_cli stat");
        print ">>>> check wpa state : $i\n@arr\n";
        my $str = join "", @arr;
        if ($str =~ m/ssid=$ssid/si && $str =~ m/wpa_state=COMPLETED/si) {
            return 1;
        }
        sleep $check_interval;
    }
    return 0;
}

#eth1      Link encap:Ethernet  HWaddr 00:0C:29:51:8A:D3  
#          inet addr:192.168.41.1  Bcast:192.168.41.255  Mask:255.255.255.0
#          inet6 addr: fe80::20c:29ff:fe51:8ad3/64 Scope:Link
#          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
#          RX packets:342815 errors:0 dropped:0 overruns:0 frame:0
#          TX packets:10508 errors:0 dropped:0 overruns:0 carrier:0
#          collisions:0 txqueuelen:1000 
#          RX bytes:35474706 (33.8 MiB)  TX bytes:758756 (740.9 KiB)

#wls160: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
#        inet 192.168.41.183  netmask 255.255.255.0  broadcast 192.168.41.255
#        inet6 fe80::9639:e5ff:fe7b:9c4b  prefixlen 64  scopeid 0x20<link>
#        ether 94:39:e5:7b:9c:4b  txqueuelen 1000  (Ethernet)
#        RX packets 4673  bytes 363968 (355.4 KiB)
#        RX errors 0  dropped 0  overruns 0  frame 25912
#        TX packets 2233  bytes 243049 (237.3 KiB)
#        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
#        device interrupt 18  

sub get_dhcp_server_lin{
    my $lease_file = '/var/lib/dhclient/dhclient.leases';
    
    my $str = `cat $lease_file | grep "dhcp-server-identifier"`;
    return ($str =~ m/(\d+\.\d+\.\d+\.\d+)/) ? $1 : ""
}

sub get_dns_servers_lin{
    my $lease_file = '/var/lib/dhclient/dhclient.leases';
    
    my $str = `cat $lease_file | grep "domain-name-servers"`;
    push @DNS_SERVERS, $1 while ($str =~ m/(\d+\.\d+\.\d+\.\d+)/g);
}

sub is_dhclient_ok {
    my $ifname = shift;
    my $rc = 0;
    
    run(">/var/lib/dhclient/dhclient.leases");
    run("dhclient -timeout 30 $ifname");
    my @ifconfig = run("ifconfig $ifname");
    print ">>>> @ifconfig\n";
    foreach my $line (@ifconfig) {
        if ($line =~ m/inet (addr:)?(\d+\.\d+\.\d+\.\d+)/) {
            $rc = $2;
            next;
        }
        if ($line =~ m/HWaddr ([\w:]+)/ || $line =~ m/ether ([\w:]+)/) {
            $MAC = $1;
            $MAC =~ s/(\w\w):(\w\w)/$1$2/g;
            $MAC = lc $MAC;
            next;
        }
        if ($line =~ m/RX packets/) {
            last;
        }
    }
    if ($rc) {
        $DHCP_SERVER = get_dhcp_server_lin();
        get_dns_servers_lin();
    }
    return $rc;
}

sub is_ping_dhcp_ok {
    my $dhcp = shift;
    
    my $c = 20;
    my $packet_loss;
    
    run("ping -c 1 $dhcp");
    my @ping = run("ping -c $c $dhcp");
    print ">>>> @ping\n";
    for(my $i = $#ping; $i > 0; $i--) {
        if ($ping[$i] =~ m/ (\d+)% packet loss,/) {
            $packet_loss = $1;
            last;
        }
    }
    #foreach my $line (@ping) {
    #    if ($line =~ m/from.*ttl=/i) {
    #        return 1;
    #    }
    #}
    #return 0;
    
    return ($packet_loss >= 20) ? 0 : 1;
}

#AH-830ec0#security-object autoap security protocol-suite 
#    802.1x            Set the security protocol suite as 802.1X
#                      authentication
#    open              Set network access as 'open', meaning that user traffic
#                      is neither authenticated nor encrypted
#    wep-open          Set the security protocol suite as preshared-key key
#                      management, WEP40/WEP104 encryption, and open
#                      authentication
#    wep-shared        Set the security protocol suite as preshared-key key
#                      management, WEP40/WEP104 encryption, and preshared-key
#                      authentication
#    wep104-8021x      Set the security protocol suite as 104-bit WEP
#                      encryption and EAP (802.1x) authentication
#    wep40-8021x       Set the security protocol suite as 40-bit WEP
#                      encryption and EAP (802.1x) authentication
#    wpa-aes-8021x     Set the security protocol suite as WPA-EAP (802.1X) key
#                      management, AES-CCMP encryption, and EAP (802.1X)
#                      authentication
#    wpa-aes-psk       Set the security protocol suite as WPA-PSK (preshared
#                      key) key management, AES-CCMP encryption, and open
#                      authentication
#    wpa-auto-8021x    Set security protocol suite as WPA-/WPA2-EAP (802.1X)
#                      key management, TKIP/AES-CCMP encryption, and EAP
#                      (802.1X) authentication
#    wpa-auto-psk      Set security protocol suite as WPA-/WPA2-PSK (preshared
#                      key) key management, TKIP or AES-CCMP encryption, open
#                      authentication
#    wpa-tkip-8021x    Set the security protocol suite as WPA-EAP (802.1X) key
#                      management, TKIP encryption, and EAP (802.1X)
#                      authentication
#    wpa-tkip-psk      Set the security protocol suite as WPA-PSK (preshared
#                      key) key management, TKIP encryption, and open
#                      authentication
#    wpa2-aes-8021x    Set the security protocol suite as WPA2-EAP (802.1X)
#                      key management, AES-CCMP encryption, and EAP (802.1X)
#                      authentication
#    wpa2-aes-psk      Set the security protocol suite as WPA2-PSK (preshared
#                      key) key management, AES-CCMP encryption, and open
#                      authentication
#    wpa2-tkip-8021x   Set the security protocol suite as WPA2-EAP (802.1X)
#                      key management, TKIP encryption, and EAP (802.1X)
#                      authentication
#    wpa2-tkip-psk     Set the security protocol suite as WPA2-PSK (preshared
#                      key) key management, TKIP encryption, and open
#                      authentication

sub conn_with_wpacli {
    my $obj = shift;
    my @clis = (
        'disc',
        'reconfig',
        'add_network',
        "set_network 0 ssid \"$obj->{'ssid'}\"",
    );
    
    #use bssid to distinguish different interface under the same ssid
    push @clis, "set_network 0 bssid $obj->{'bssid'}" if $obj->{'bssid'};
    
    $Expect::Log_Stdout = 1;
    #$Expect::Debug = 1;
    #$ENV{TERM} = "vt100";
    my $exp = Expect->spawn("wpa_cli");
    #$exp->log_file("/tmp/connect_wifi.log", "w");
    
    my $proto = $obj->{'proto'};
    if ($proto =~ m/^open$/i) {
        push @clis, "set_network 0 key_mgmt NONE";
    }
    elsif($proto =~ m/wep-open/i) {
        push @clis, "set_network 0 key_mgmt NONE";
        if ($obj->{'psk_keytype'} =~ m/ascii/i) {
            push @clis, "set_network 0 wep_key$obj->{'keyidx'} \"$obj->{psk}\"";
        }
        elsif($obj->{'psk_keytype'} =~ m/hex/i) {
            push @clis, "set_network 0 wep_key$obj->{'keyidx'} $obj->{psk}";
        }
        push @clis, "set_network 0 wep_tx_keyidx $obj->{'keyidx'}";
    }
    elsif($proto =~ m/wep-shared/i) {
        push @clis, "set_network 0 key_mgmt NONE";
        push @clis, "set_network 0 auth_alg SHARED";
        if ($obj->{'psk_keytype'} =~ m/ascii/i) {
            push @clis, "set_network 0 wep_key$obj->{'keyidx'} \"$obj->{psk}\"";
        }
        elsif($obj->{'psk_keytype'} =~ m/hex/i) {
            push @clis, "set_network 0 wep_key$obj->{'keyidx'} $obj->{psk}";
        }
        push @clis, "set_network 0 wep_tx_keyidx $obj->{'keyidx'}";
    }
    elsif($proto =~ m/wep104-8021x/i || $proto =~ m/wep40-8021x/i) {
        push @clis, "set_network 0 key_mgmt IEEE8021X";
        if (has($obj, 'group')) {
            push @clis, "set_network 0 group $obj->{'group'}";
        }
        push @clis, "set_network 0 identity \"$obj->{'username'}\"";
        push @clis, "set_network 0 password \"$obj->{'password'}\"";
        if (has($obj, 'anonymous_identity')) {
            push @clis, "set_network 0 eap TTLS";
            push @clis, "set_network 0 phase2 \"auth=$obj->{'inner_auth'}\"";
            push @clis, "set_network 0 anonymous_identity \"$obj->{'username'}\"";
        }
        else {
            if ($obj->{'eap_type'} =~ m/^TTLS$/i) {
                push @clis, "set_network 0 proactive_key_caching \"1\"";
                push @clis, "set_network 0 eap $obj->{'eap_type'}";
            }
            elsif($obj->{'eap_type'} =~ m/^TLS$/i) {
                push @clis, "set_network 0 proactive_key_caching \"1\"";
                push @clis, "set_network 0 eap $obj->{'eap_type'}";
                push @clis, "set_network 0 ca_cert \"$obj->{'cacert'}\"";
                push @clis, "set_network 0 client_cert \"$obj->{'client_cert'}\"";
                push @clis, "set_network 0 private_key \"$obj->{'private_key'}\"";
                push @clis, "set_network 0 private_key_passwd \"$obj->{'private_key_passwd'}\"";
            }
        }
    }
    elsif($proto =~ m/wpa-tkip-psk/i) {
        push @clis, "set_network 0 key_mgmt WPA-PSK";
        push @clis, "set_network 0 proto WPA";
        push @clis, "set_network 0 pairwise TKIP";
        push @clis, "set_network 0 group TKIP";
        push @clis, "set_network 0 psk \"$obj->{'psk'}\"";
    }
    elsif($proto =~ m/wpa-aes-psk/i) {
        push @clis, "set_network 0 key_mgmt WPA-PSK";
        push @clis, "set_network 0 proto WPA";
        push @clis, "set_network 0 pairwise CCMP";
        push @clis, "set_network 0 group CCMP";
        #push @clis, "set_network 0 psk \"$obj->{'psk'}\"";
        if ($obj->{'psk_keytype'} =~ m/ascii/i) {
            push @clis, "set_network 0 psk \"$obj->{'psk'}\"";
        }
        elsif($obj->{'psk_keytype'} =~ m/hex/i) {
            push @clis, "set_network 0 psk $obj->{'psk'}";
        }
    }
    elsif($proto =~ m/wpa-auto-psk/i) {
        push @clis, "set_network 0 key_mgmt WPA-PSK";
        push @clis, "set_network 0 proto WPA";
        push @clis, "set_network 0 psk \"$obj->{'psk'}\"";
    }
    elsif($proto =~ m/wpa2-tkip-psk/i) {
        push @clis, "set_network 0 key_mgmt WPA-PSK";
        push @clis, "set_network 0 proto RSN";
        push @clis, "set_network 0 pairwise TKIP";
        push @clis, "set_network 0 group TKIP";
        push @clis, "set_network 0 psk \"$obj->{'psk'}\"";
    }
    elsif($proto =~ m/wpa2-aes-psk/i) {
        push @clis, "set_network 0 key_mgmt WPA-PSK";
        push @clis, "set_network 0 proto RSN";
        push @clis, "set_network 0 pairwise CCMP";
        push @clis, "set_network 0 group CCMP";
        push @clis, "set_network 0 psk \"$obj->{'psk'}\"";
    }
    elsif($proto =~ m/wpa-tkip-8021x/i || $proto =~ m/wpa-aes-8021x/i) {
        push @clis, "set_network 0 key_mgmt WPA-EAP";
        push @clis, "set_network 0 proto WPA";
        if ($obj->{'pairwise'}) {
            push @clis, "set_network 0 pairwise $obj->{'pairwise'}";
        }
        if ($obj->{'group'}) {
            push @clis, "set_network 0 group $obj->{'group'}";
        }
        push @clis, "set_network 0 eap $obj->{'eap_type'}";
        push @clis, "set_network 0 identity \"$obj->{'username'}\"";
        if ($obj->{'eap_type'} =~ m/TLS/i) {
            push @clis, "set_network 0 ca_cert \"$obj->{'cacert'}\"";
            push @clis, "set_network 0 client_cert \"$obj->{'client_cert'}\"";
            push @clis, "set_network 0 private_key \"$obj->{'private_key'}\"";
            push @clis, "set_network 0 private_key_passwd \"$obj->{'private_key_passwd'}\"";
        }
        else {
            push @clis, "set_network 0 phase2 \"auth=$obj->{'inner_auth'}\"";
            push @clis, "set_network 0 password \"$obj->{'password'}\"";
        }
    }
    elsif($proto =~ m/wpa-auto-8021x/i) {
        push @clis, "set_network 0 key_mgmt WPA-EAP";
        push @clis, "set_network 0 proto $obj->{'accepted_proto'}";
        push @clis, "set_network 0 pairwise CCMP";
        push @clis, "set_network 0 group TKIP";
        push @clis, "set_network 0 eap $obj->{'eap_type'}";
        push @clis, "set_network 0 phase2 \"auth=MSCHAPV2\"";
        push @clis, "set_network 0 identity \"$obj->{'username'}\"";
        push @clis, "set_network 0 anonymous_identity \"$obj->{'username'}\"";
        push @clis, "set_network 0 password \"$obj->{'password'}\"";
    }
    elsif($proto =~ m/wpa2-tkip-8021x/i || $proto =~ m/wpa2-aes-8021x/i) {
        push @clis, "set_network 0 proactive_key_caching \"1\"";
        push @clis, "set_network 0 key_mgmt WPA-EAP";
        push @clis, "set_network 0 proto RSN";
        if ($obj->{'pairwise'}) {
            push @clis, "set_network 0 pairwise $obj->{'pairwise'}";
        }
        if ($obj->{'group'}) {
            push @clis, "set_network 0 group $obj->{'group'}";
        }
        push @clis, "set_network 0 eap $obj->{'eap_type'}";
        push @clis, "set_network 0 phase2 \"auth=$obj->{'inner_auth'}\"";
        push @clis, "set_network 0 identity \"$obj->{'username'}\"";
        
        if ($obj->{'eap_type'} =~ m/TLS/i) {
            push @clis, "set_network 0 ca_cert \"$obj->{'cacert'}\"";
            push @clis, "set_network 0 client_cert \"$obj->{'client_cert'}\"";
            push @clis, "set_network 0 private_key \"$obj->{'private_key'}\"";
            push @clis, "set_network 0 private_key_passwd \"$obj->{'private_key_passwd'}\"";
        }
        else {
            push @clis, "set_network 0 password \"$obj->{'password'}\"";
        }
    }

    push @clis, "set_network 0 priority 5";
    push @clis, "select_network 0";
    
    for(my $i = 0; $i <= $#clis; $i++) {
        if ($exp->expect(5, "> ")) {
            $exp->clear_accum();
            $exp->send("$clis[$i]\n");
            sleep 1;
        }
        if ($i == $#clis) {
            $exp->clear_accum();
            $exp->send("quit\n\n");
            sleep 10;
        }
    }
}

sub obj_init {
    my $obj = shift;
    
    unless (has($obj, 'ssid')) {
        return 1;
    }
    unless (has($obj, 'ifname')) {
        return 2;
    }
    unless (has($obj, 'target')) {
        $obj->{'target'} = 'sta1';
    }
    unless (has($obj, 'bind')) {
        $obj->{'bind'} = 'wifi0';
    }
    unless (has($obj, 'proto')) {
        $obj->{'proto'} = 'open';
    }
    unless (has($obj, 'psk_keytype')) {
        $obj->{'psk_keytype'} = 'ascii';
    }
    unless (has($obj, 'eap_type')) {
        $obj->{'eap_type'} = 'PEAP';
    }
    unless (has($obj, 'inner_auth')) {
        $obj->{'inner_auth'} = 'MSCHAPV2';
    }
    unless (has($obj, 'check_ping')) {
        $obj->{'check_ping'} = 'bidirectional';
    }
    unless (has($obj, 'auth_negative_test')) {
        $obj->{'auth_negative_test'} = 'false';
    }
    unless (has($obj, 'dhcp_negative_test')) {
        $obj->{'dhcp_negative_test'} = 'false';
    }
    #format bssid to five delimiters, and the delimiter must be :
    if (has($obj, 'bssid')) {
        $obj->{'bssid'} =~ s/[^0-9a-f]//gi;
        $obj->{'bssid'} =~ s/(\w\w)(?!$)/$1:/g;
    }
    
    if (has($obj, 'password')) {
        unless (has($obj, 'private_key_passwd')) {
            $obj->{'private_key_passwd'} = $obj->{'password'}
        }
    }
    
    if ($obj->{'proto'} =~ m/wpa-auto-8021x/i) {
        unless (has($obj, 'accepted_proto')){
            $obj->{'accepted_proto'} = 'WPA';
        }
    }
    

    if ($obj->{'eap_type'} =~ m/TLS/i) {
        if (has($obj, 'certs_server')) {
            $certs_server = $obj->{certs_server};
        }
        $obj->{'cacert'} = "/tmp/cacert.pem";
        $obj->{'client_cert'} = "/tmp/client.pem";
        $obj->{'private_key'} = "/tmp/client.key";
        `tftp $certs_server -c get radius_certs_$certs_server/cacert.pem $obj->{'cacert'}`;
        `tftp $certs_server -c get radius_certs_$certs_server/client.pem $obj->{'client_cert'}`;
        `tftp $certs_server -c get radius_certs_$certs_server/client.key $obj->{'private_key'}`;
        unless(-e $obj->{'cacert'} && -e $obj->{'client_cert'} && -e $obj->{'private_key'}) {
            return 253;
        }
    }
    
    return 0;
}

sub connect_wifi_lin {
    my $obj = shift;
    
    my $rc = obj_init($obj);
    return $rc if $rc;
    
    print ">>>>", Dumper($obj);
    
    my $try = 1;
    my $stepInterval = 1;
    $rc = 0;
    START:
    if ($try > 2) {
        #return !defined($obj->{'auth_negative_test'});
        if ($obj->{'auth_negative_test'} =~ m/true/i) {
            if ($rc == 7) {
                print ">>>> Auth negative test is true, pass\n";
                $rc = 0;
            }
            else {
                $rc = 3;
            }
        }
        if ($obj->{'dhcp_negative_test'} =~ m/true/i && $rc == 7) {
            if ($rc == 8) {
                print ">>>> DHCP negative test is true, pass\n";
                $rc = 0;
            }
            else {
                $rc = 4;
            }
        }
        return $rc;
    }
    
    print ">>>> start try times: $try\n";
    run("echo \"ctrl_interface=/var/run/wpa_supplicant\" > /tmp/wpa_supplicant.cfg");
    run("killall -q wpa_supplicant");
    run("dhclient -r $obj->{'ifname'}");
    run("killall -q dhclient");
    run("wpa_supplicant -i $obj->{ifname} -Dnl80211,wext -c /tmp/wpa_supplicant.cfg -B");
    if ($?) {
        print ">>>> wpa_supplicant fail, $@\n";
        $try++;
        $rc = 5;
        goto START;
    }
    sleep $stepInterval;
    
    #check interface is up
    unless (is_interface_up($obj->{'ifname'})) {
        print ">>>> Interace [$obj->{ifname}] is not up\n";
        $try++;
        $rc = 6;
        goto START;
    }
    sleep $stepInterval;
    
    #scan ssid before connection
    #this will improve wifi1 connection especially on BCM4321 cards
    run("iw dev $obj->{'ifname'} scan ssid $obj->{'ssid'} >/dev/null");
    
    #start connect wifi with wpa_cli command
    conn_with_wpacli($obj);
    unless (is_connect_complete($obj->{'ssid'})) {
        print ">>>> WPA state is not complete\n";
        $try++;
        $rc = 7;
        goto START;
    }
    sleep $stepInterval;
    
    $IP = is_dhclient_ok($obj->{'ifname'});
    unless ($IP) {
        print ">>>> Cannot get IP address\n";
        $try++;
        $rc = 8;
        goto START;
    }
    sleep $stepInterval;
    
    if ($obj->{'check_ping'} =~ m/(bidirectional|statodhcp)/i ) {
        unless (is_ping_dhcp_ok($DHCP_SERVER)) {
            print ">>>> Ping DHCP server: $DHCP_SERVER failed\n";
            $try++;
            $rc = 9;
            goto START;
        }
    }
    
    print ">>>> connect wifi success\n";
    #return variables to caller
    print "<<<<$obj->{'target'}.tif.ip=$IP\n";
    print "<<<<$obj->{'target'}.tif.mac=$MAC\n";
    print "<<<<$obj->{'target'}.dhcp_server.ip=$DHCP_SERVER\n";
    for my $i (0..$#DNS_SERVERS){
        print "<<<<$obj->{'target'}.dns_server", $i + 1,".ip=$DNS_SERVERS[$i]\n";
    }
    return 0;
}

sub connect_wifi_win {
    
}

sub connect_wifi_mac {
    
}

sub main {
    
}

if (valid_json($json)) {
    $perlObj = parse_json($json);
    print ">>>> Get object: \n", Dumper($perlObj), "\n";
}
else {
    print ">>>> JSON Object is invalid: $@\n";
    exit 254;
}

my $rc = 255;
if ($^O eq 'linux') {
    $rc = connect_wifi_lin($perlObj);
}
elsif ($^O eq 'MSWin32') {
    $rc = connect_wifi_win($perlObj);
}
elsif ($^O eq 'MacOS') {
    $rc = connect_wifi_mac($perlObj);
}

print "\n>>>> $returnCode{$rc} <<<<\n";
exit $rc;

