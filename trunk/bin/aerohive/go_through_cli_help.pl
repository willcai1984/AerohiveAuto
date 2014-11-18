#!/usr/bin/perl -w

use strict;
use Expect;
use Cwd 'abs_path';
use Control::CLI;
#use Data::Dumper;
use Pod::Usage;
use Getopt::Long;
use Sourcecode::Spellchecker;

our $cli = '';
our %words = (
    '<cr>' => '<cr>',
    #Enter the name of the aggregate interface, where x = 0
    '<aggx>' => 'agg0',
    #Enter the name of the BGD (Bonjour Gateway Daemon) interface
    #(Ranges: x: 0; y: 1-16)
    '<bgdx.y>' => 'bgd0.1',
    #Enter the pool of channels from which the radio can select
    #one to use (Format: xx-xx-xx;)
    '<channel_g3>' => '01-06-11',
    #Enter the pool of channels from which the radio can select
    #one to use (Format: xx-xx-xx-xx;)
    '<channel_g4>' => '01-05-09-13',
    #Enter the start date and time of the date (Format:
    #YYYY-MM-DD/hh:mm:ss; Range: 1970-01-01 to 2035-12-31/hh
    #(00-23), mm (000-59), ss (000-59))
    '<date/time>' => '2014-08-29/17:59:00',
    #Enter a start date for the schedule (Format: yyyy-mm-dd; Range:
    #1970-01-01 to 2035-12-31)
    '<date>' => {
        qr/daylight saving time/ => '01-01',
        qr/(?!daylight saving time)/ => '2014-08-29',
    },
    #Enter the name of an Ethernet interface, where x = 0 or 1
    '<ethx>' => 'eth0',
    #<hex>   Enter the value indicating an ethernet type (ARP:0806; IP:0800;
    #IPX:8137; RARP:8035)
    '<hex>' => '0800',
    #Enter the IP address and netmask of the multicast group
    #to block (Example: 224.1.1.1 or 224.1.1.0/24)
    '<ip_addr/netmask>' => '10.155.44.40/24',
    #Enter the IP address and netmask of the multicast group
    #to block (Example: 224.1.1.1 or 224.1.1.0/24)
    '<ip_addr>' => '10.155.44.40',
     #Enter the protocol, SCP user name, location, path, file
    #name, and SCP port number (Range: 1-256 chars; Default SCP
    #port number: 22; Format: tftp://location:path/filename,
    #scp://username@location:path/filename or
    #scp://username@location:port:path/filename)
    '<location>' => 'tftp://192.168.10.201/test.txt',
    #Enter a MAC address (Note: You can use colons, dashes, or
    #periods to format the address. Examples: 1111:1111:1111,
    #11-11-11-11-11-11, 1111.1111.1111 ...)
    '<mac_addr>' => '1111:1111:1111',
    #Enter a netmask or IP wildcard mask in which 0 masks the octet
    #where it appears (For example, the 0s in '255.0.0.255' mask the
    #second and third octets, applying the IP policy to all
    #addresses matching only the first and fourth octets.)
    '<mask>' => '255.255.255.0',
    #Enter the name of the virtual management interface (Ranges:
    #x: 0; y: 1-16)
    '<mgtx.y>' => 'mgt0.1',
    #Enter the name of the management interface, where x = 0
    '<mgtx>' => 'mgt0',
    #<netmask>   Enter the IP netmask
    '<netmask>' => '255.255.255.0',
    '<number>' => '',
    #Enter the OUI (Note: You can use colons, dashes, or periods to
    #format the OUI. Examples: Apple iPhone=00:1b:63; D-Link
    #Phone=00-17-9a; Vocera=00.09.ef.)
    '<oui>' => '00:1b:63',
    #Enter the port number (Default: 6001; Range: 1-65535)
    '<port>' => '2096',
    #Enter the name of the redundant interface, where x = 0
    '<redx>' => 'red0',
    '<string>' => '<string>',
    #Show messages time (Format: hh:mm:ss)
    '<time>' => {
        qr/Format: hh:mm;/ => '11:11',
        qr/(?!Format: hh:mm;)/ => '11:11:11'
    },
    #Enter the name of the tunnel interface, where x = 0 or 1
    '<tunnelx>' => 'tunnel0',
    #Enter the HTTP protocol, remote server domain name, port,
    #directory path, and file name (Default port: 80; 1-256 chars;
    #Format: http://domain/path or http://domain:port/path; Note: You
    #can substitute "https" for "http".)
    '<url>' => 'http://10.155.44.40/test.txt',
    #Enter the name of the wireless USB modem interface, where x = 0
    '<usbnetx>' => 'usbnet0',
    #Enter the name of a Wi-Fi radio subinterface (Ranges: x: 0-1; y: 1-16)
    '<wifix.y>' => 'wifi0.1',
    #Enter the name of a Wi-Fi radio interface, where x = 0 or 1
    '<wifix>' => 'wifi0',
);

my $man = 0;
my $help = 0;
my $debug = 0;
my $ip = '';
my $spellcheck = 1;
my $fast = 1;
my $username = 'admin';
my $password = 'aerohive';
my $logfile = 'input.log';
my $xmlfile = '';
my @baseclis = ();

GetOptions(
	'help|?'       => \$help,
	'man'          => \$man,
    'debug|d'      => \$debug,
	'target|t=s'   => \$ip,
    'spellcheck!'  => \$spellcheck,
    'fast!'        => \$fast,
    'username|u=s' => \$username,
    'password|p=s' => \$password,
    'logfile|l=s'  => \$logfile,
    'xmlfile|x=s'  => \$xmlfile,
    'base|b=s'     => \@baseclis,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

sub connect_device {
    my $cli = '';
    $cli = new Control::CLI(
        Use => 'telnet',
        Input_log => $logfile,
        #Output_log => 'output.log',
    );
    $cli->connect($ip);
    $cli->login(
        Username => $username,
        Password => $password,
    );
    my @output = $cli->cmd("show version");
    #print Dumper(\@output);
    if ($output[0] =~ m/Aerohive Networks Inc/i) {
        print "Telnet device OK!\n";
        $cli->cmd("console page 0");
        $cli->cmd("no hostname");
        return $cli;
    }
    else{
        die "Cannot telnet $ip, $!\n";
    }
}

sub push_to_array {
    my ($arr, $hash, $push_cli, $help, $prefix) = @_;
    
    if ($push_cli =~ m/^<.+>$/) {
        if ($fast) {
            if (defined($hash->{$help})) {
                return;
            }
            else {
                $hash->{$help} = 1;
                push @{$arr}, [replace_value($push_cli, $help, $prefix), $push_cli];
                return;
            }
        }
        push @{$arr}, [replace_value($push_cli, $help, $prefix), $push_cli];
    }
    elsif ($push_cli) {
        push @{$arr}, [$push_cli, $push_cli];
    }
}

# This subroutine transform a help string to array ([$cli, $its_help], [])
# As help may have duplicate entry, this sub will also find out it.
sub to_array {
    my $str = shift;
    my $prefix = shift;
    
    my %entries = ();
    my %hhash = ();
    my @cli_replaced = ();
    
    my @tmp = grep { !/^\s*$/ } split(/\n/, $str);
    my $current = '';
    my $help = '';
    foreach (@tmp){
        if (m/^    (\S+)\s+(.*)/) {
            if (defined($entries{$1})) {
                warn "\nWARN ==> Duplicate entry found, [ $1 ]\n",
                     "@@ $prefix @@\n";
                $help .= $2;
            }
            else {
                push_to_array(\@cli_replaced, \%hhash, $current, $help, $prefix)
                  if $current;
                $entries{$1} = 1;
                $current = $1;
                $help = $2;
            }
        }
        elsif (m/^    \s+(.*)/) {
            $help .= $1;
        }
        elsif (m/AH-\w+#/) {
            
        }
        elsif (m/unknown keywork or invalid input/) {
            warn "WARN ==> Replace value is not correct\n",
                 "@@ $prefix @@\n";
        }
        else {
            warn "\nWARN ==> Unhandled line, \n",
                 "<$_>\n",
                 "@@ $prefix @@\n";
        }
    }
    
    push_to_array(\@cli_replaced, \%hhash, $current, $help, $prefix) if $current;
    
    return \@cli_replaced;
}

sub replace_value {
    my ($segment, $help, $prefix) = @_;
    
    return $segment unless($segment =~ m/^<.+>$/);
    
    if (defined($words{$segment})) {
        my $value = $words{$segment};
        if (ref $value) {
            #more than one values can be used, need help message to do further decision
            $help =~ s/[\n\r]/ /g;
            foreach my $regexp (keys %{$value}) {
                return $value->{$regexp} if ($help =~ m/$regexp/);
            }
            warn "\nWARN ==> Cannot do value replacement for [ $segment ]\n",
                 "Help message: \n<$help>\n",
                 "@@ $prefix @@\n";
            return $segment;
        }
        elsif($value) {
            # Only one value
            return $value;
        }
        else {
            #need parse value from help message
            $help =~ s/[\n\r]/ /g;
            if ($segment eq '<number>') {
                if ($help =~ m/Default:\s*(-?\d+)/i) {
                    return $1;
                }
                elsif ($help =~ m/Range:?\s*(-?\d+)/i) {
                    return $1;
                }
                elsif ($help =~ m/(-?\d+)\s*[-~]\s*-?\d+/) {
                    return $1;
                }
                elsif ($help =~ m/:\s*(-?\d+)/i) {
                    return $1;
                }
                else {
                    return 1;
                }
            }
            else {
                warn "\nWARN ==> Cannot find a suitable value for [ $segment ]\n",
                     "Help message: \n<$help>\n",
                     "@@ $prefix @@\n";
                return $segment;
            }
        }
    }
    else {
        warn "\nWARN ==> Cannot do value replacement for [ $segment ]. No record\n",
             "@@ $prefix @@\n";
        return $segment;
    }
}


sub go_through_cli_help {
    my $cli_prefix = shift;
    my $orig_cli = shift;
    
    #flush the input
    $cli->cmd();
    
    print "\n==>> Ready to get help of [ $cli_prefix ]\n" if $debug;
    
    if ($xmlfile) {
        if (!$cli_prefix) {
            print XML "<node TEXT=\"root\">\n";
        }
        elsif ($orig_cli && $orig_cli =~ m/(\S+)\s*$/) {
            print XML "<node TEXT=\"$1\">\n";
        }
        else {
            print XML "<node TEXT=\"$cli_prefix\">\n";
        }
    }
    
    $cli->put("$cli_prefix ");
    my $echoed_cli = $cli->readwait(
        blocking => 1,
    );
    #password will be echoed as "*" which is a meta-char in regexp, escape it.
    $echoed_cli =~ s/\*/\\*/g;
    $cli->put("?");

    my $help_str = $cli_prefix ? $cli->waitfor(qr/$echoed_cli.*$/) : $cli->waitfor(qr/AH-\w+.*$/);
    
    #clear input buff, or else the cli will be executed
    $cli->cmd("\b" x (length($cli_prefix) + 1));
    
    my @cli_help = @{to_array($help_str, $cli_prefix)};
    
    #11a-rate-set and 11g-rate-set have too many combination, skip this cli
    #11a-rate-set -> 3 ^ 8 = 6561
    #11g-rate-set -> 3 ^ 12 = 531441
    return if(!$fast && $cli_prefix =~ m/11[ag]-rate-set/i);
    
    foreach my $r (@cli_help){
        if ($r->[0] eq '<cr>') {
            print "\nCLI [ $cli_prefix ] goes the end\n" if $debug
        }
        else {
            go_through_cli_help("$cli_prefix $r->[0]", "$r->[1]");
        }
    }
    
    print XML "</node>\n" if $xmlfile;
}

sub spell_check {
    my $file = shift;
    
    print "\nReady to check misspelling for file <" . abs_path($file) . ">\n"
      if $debug;
    
    my $checker = new Sourcecode::Spellchecker;
    my @results = $checker->spellcheck($file);
    if (@results) {
        foreach my $r (@results) {
            print "$r->{line}: '$r->{misspelling}' should be '$r->{correction}'\n";
        }
    }
    else {
        print "No spelling mistakes found.\n";
    }
    
}

sub main {}
$cli = connect_device();

if ($xmlfile) {
    open(XML, ">", $xmlfile) or die "Cannot open file $xmlfile, $!";
    print XML "<map version=\"1.0.1\">\n";
}

if (@baseclis) {
    foreach (@baseclis) {
        go_through_cli_help("$_");
    }
}
else {
    go_through_cli_help("");
}

$cli->close();

if ($xmlfile) {
    print XML "</map>\n";
    close XML;
}

`sed -i 's/\r//g' input.log`;
`sed -i 's/.*\x08.*//' input.log`;
spell_check("input.log") if $spellcheck;

1;

=head1 NAME

go_through_cli_help.pl - This tool will do CLI help traversal via typing a "?"
in the end of CLI segment.And then check misspelling of the help information.

=head1 SYNOPSIS

go_through_cli_help.pl [options]

=over 12

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<--help|-h>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<--debug|-d>

print debug message.

=item B<--target|-t>

Set target to telnet

=item B<--nospellcheck>

Turn off misspelling check.

=item B<--nofast>

Turn off fast mode.
This will try all combinations of CLI, and may run days and nights.

=item B<--username|-u>

Specify username for login device. Default: admin

=item B<--password|-p>

Specify password for login device. Default: aerohive

=item B<--logfile|-l>

Specify filename to store help message. Default: input.log

=item B<--xmlfile|-x>

Specify filename to store xml format output which can be used to generate tree
by other tools (freemind for example).

=item B<--base|-b>

Specify base CLI to start with, or else go through all CLIs.

=back

=head1 EXAMPLES

Firstly, make sure your device can be telnet.

perl go_through_cli_help.pl -t 192.168.41.196

perl go_through_cli_help.pl -t 192.168.41.196 -b "ssid"

perl go_through_cli_help.pl -t 192.168.41.196 -b "no" --nospellcheck

=head1 AUTHOR

hcheng@aerohive.com

=cut
