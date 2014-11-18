#!/usr/bin/perl -w
################################################################################
# File Name: parse_pcap.pl
# Author: Gengxiang Meng
# Description: This script is use to parse pcap(tree format) file
################################################################################
use strict;
use warnings;
use diagnostics;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use File::Find;
use XML::Simple;
use Data::Dumper;
use Time::Local;



##########################################################
#Global Variable defined
##########################################################

my $rc;
my $FAIL=0;
my $PASS=1;
my $NOTDEFINED="undefined";
my @junk = split( /\//, $0);
my $script_name = $junk[$#junk];
$script_name =~ s/\.pl$//;
my @keywords;
my @results;
my @output;
my @sum_pkt;
my @detail_pkt;
my @packet_section_str = (
        "Arrival Time",
        "Address",
        "Beacon Interval",
        "SSID",
        "Tag interpretation",
        "Preamble",
        "Data Rate",
        "Vendor Specific");

my %userinput = (
        "debug"=>0,
        "file"=>$NOTDEFINED,
        "keyword"=>$NOTDEFINED,
        "result"=>0,
        "pkt_index"=>0,
        "output_all"=>0,
);

##########################################################
# sub routine
##########################################################
 

##########################################################
# sub routine get pkt specified field  
##########################################################
sub pkt_field_filter {
        my $filter_str = '^\w+|^$';
        my $field;
        my @buf;
        my $cnt = 0;
        my ($skip, $line, $tmppkt);
       
        for $field (@packet_section_str) {
                $filter_str .= '|'.$field;
        } 
        print "$filter_str\n" if ($userinput{debug});
        @buf = `grep -E "$filter_str" -i $userinput{file}`;

        foreach $line (@buf) {               
                $skip = 0;
                if ($line !~ /^\s*$/) {
                        $tmppkt .= $line;
                } else {                         
                        foreach my $keyword (@keywords) {
                                if ($tmppkt =~ /$keyword/i) {
                                        next;
                                } else {
                                        #print "skip the pkt, no keyword $keyword match\n" if ($userinput{debug});                                        
                                        $skip = 1;
                                        last;
                                }
                        }                        
                        if (!$skip) {
                                $sum_pkt[$cnt] = $tmppkt;
                                $cnt++;
                        } 
                        $tmppkt = "";
                }  
        }   
        if ($userinput{debug}) {
                foreach (@sum_pkt) { 
                        print;
                }
        }

        return 0;
        
}


##########################################################
# sub routine get pkt via filter
##########################################################
sub pkt_filter {
        my $cnt = 0;
        my ($skip, $line);
        my $tmppkt = "";

        my $rc = $FAIL;
        open(FD,"<$userinput{file}") or die "can't open the file $userinput{file}";
        while (<FD>) {
                $skip = 0;
                $line = $_;
                if (($line !~ /^\s*$/) && ($line !~ /^Frame/)) {
                        $tmppkt .= $line;
                } else {                         
                        foreach my $keyword (@keywords) {
                                if ($tmppkt =~ /$keyword/i) {
                                        next;
                                } else {
                                        #print "skip the pkt, no keyword $keyword match\n" if ($userinput{debug});                                       
                                        $skip = 1;
                                        last;
                                }
                        }                        
                        if (!$skip) {
                                #found packet match
                                $rc = $PASS;
                                $detail_pkt[$cnt] = $tmppkt;
                                $cnt++;
                        } 
                        $tmppkt = ""; 
                        if ($line !~ /^Frame/) {
                               $tmppkt .= $line;
                        }
                }   
        }             
        close FD;
        if ($userinput{debug}) {
                foreach (@detail_pkt) { 
                    print;
                }
        }
        return $rc      
}


##########################################################
# sub routine get result user want
##########################################################
sub result_fetch {
        my $cnt = 0;
        my @buf;
        my ($value, $line, $offset);
        my %months = (
                "Jan" =>0,
                "Feb" =>1,
                "Mar" =>2,
                "Apr" =>3,
                "May" =>4,
                "Jun" =>5,
                "Jul" =>6,
                "Aug" =>7,
                "Sep" =>8,
                "Oct" =>9,
                "Nov" =>10,
                "Dec" =>11,
                );
        my ($mday, $mon, $year, $h, $m, $s);

        my $rc = $FAIL;
        foreach (@detail_pkt) { 
                @buf = split /\n/;                 
                foreach my $result (@results) {                
                        $offset = 0;
                        if ($result =~ /SSID/) {
                                $offset = 3;
                        }                        
                        for ( my $i = 0;  $i <= $#buf; $i++) {                               
                                if ($buf[$i] =~ /$result/i) {
                                        $line = $buf[$i+$offset];
                                        $line =~ s/[\r\n]//;
                                        $line =~ s/^\s+//;
                                        if ($line =~ /(\w):\s(.*)/) {
                                                $value = $2;
                                                $value =~ s/\[Seconds\]//;
                                              	$value =~ s/Mb\/s//;
                                              	#$value =~ s/\s*//g;
                                        } else {
                                                $value = $line;
                                        }
                                        print "before:$value\n" if ($userinput{debug});
                                        SWITCH_KEYWORDS:for ( $result ) {
                                        /address/i && do {                                               
                                                $value =~ s/.*\((.*)\)/$1/;                                               
                                                last;
                                                };
                                        /SSID/i && do {                                              
                                                $value =~ s/(.*):.*/$1/;                                            
                                                last;
                                                };
                                        /time/i && do {
                                        	       print "after55555555:$value\n" if ($userinput{debug}); 
                                                                               
                                                if ($value =~ /(\w+)\s+(\d+),\s+(\d+)\s+(\d+):(\d+):(\d+)\.(\d+)/) {      
                                                        $mday = $2;
                                                        $mon = $months{$1};
                                                        $year = $3 - 1900;
                                                        ($h, $m, $s) = ($4, $5, $6);
                                                        $value = timelocal($s, $m, $h, $mday, $mon, $year).".".$7;
                                                }
                                                last;
                                                };                           
                                        } 
                                        print "after:$value\n" if ($userinput{debug}); 
                                        $value =~ s/\s*//g;
                                        $output[$cnt]{$result} = $value;
                                        #found match  result
                                        $rc = $PASS;
                                        last;
                                }
                        }                                              
                }             
                $cnt++;
        }

        return $rc;
         
}


##########################################################
# sub routine result handle
##########################################################
sub result_output {
        my $cnt = 0;
        my ($format, $value);

        if (!$userinput{output_all}) {                
                defined ($output[$userinput{pkt_index}])? 
                    my %res = %{$output[$userinput{pkt_index}]} : die "No data found"; 
                foreach my $r (keys %res) {
                        print "$res{$r}";                        
                } 
                print "\n";
                return;
        }

        printf "%-6s", "No.";
        foreach my $result (sort @results) {
                printf "%-21s", "$result";
        }
        printf "\n";
        printf "%-6s", "----- ";
        foreach my $result (@results) {
                printf "%-21s", "-------------------- ";
        }
        printf "\n";
        
        foreach my $pkt (@output) {                
                printf "%-6s",  "$cnt";
                my %res = %{$pkt}; 
                foreach my $r (sort keys %res) {
                        printf "%-21s", "$res{$r}"; 
                }
                printf "\n";
                $cnt++;
        } 
           
}


##########################################################
# Main Routine
##########################################################
MAIN:
my ($option_h, $option_man);


#Get Input Parameters
$rc = GetOptions(
        "help|h"=>\$option_h,
        "man"=>\$option_man,
        "f=s"=>\$userinput{file},
        "n=i"=>\$userinput{pkt_index},
        "k=s"=>sub { push (@keywords, $_[1]); },
        "o=s"=>sub { push (@results, $_[1]); },
        "all!"=>\$userinput{output_all},
        "debug!"=>\$userinput{debug},
);

#print script usage syntax
pod2usage(1) if ($option_h);

#print man usage
pod2usage(-verbose=>2) if ($option_man);

if (pkt_filter() != $PASS) {
        print "No_match_packet_found\n";
        exit 1;
}

if (result_fetch() != $PASS) {
        print "No_match_packet_found\n";
        exit 1;
}

result_output();

exit 0;

1;
__END__

=pod

=head1 NAME

parse_pcap.pl - Use to parse wireshark capture packet file with tree format

=head1 SYNOPSIS

=over 12

=item B<parse_pcap.pl>
[B<-help|h>]
[B<-man>]
[B<-f>]
[B<-k>]
[B<-o>]
[B<-n>]
[B<-all>]
[B<-debug>]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-h>

Print a brief help message and exit.

=item B<-man>

Print a man page 

=item B<-f>

Input a pcap tree file that need to parse

=item B<-k>

Input some keyword to filter packets that you need to find

=item B<-o>

Output packet field value

=item B<-n>

Specify which packet you are interesting, default is the first matched packet field value
will be return.

=item B<-all>

Output all packet field value with table format

=item B<-debug>

Print Debug message for engineer

=back

=head1 DESCRIPTION

B<parse_pcap.pl> This is used to parse wireshark capture packet file with tree format
return value or string for user. when specify -k and -o parameters, you need to 
specify the name according to wireshark capture packet field name.before use this
tool, you need to run station to capture packet and save in a file with tree format.
when capture a packet, we advise you don't enable host name resolve, because you
may need to use Mac address as a -k parameter to filter packet.


=head1 EXAMPLES

1. Get beacon packet supported rate(source address=00:19:77:03:8d:10, destination address=00:14:78:71:9d:26)
   perl parse_pcap.pl -k "00:14:78:71:9d:26" -k "beacon" -k "00:19:77:03:8d:10"  -f packet.log  -o "Supported Rates"

2. Get all beacon packet arrival time(source address=00:19:77:03:8d:10, destination address=00:14:78:71:9d:26)
   perl parse_pcap.pl -k "00:14:78:71:9d:26" -k "beacon" -k "00:19:77:03:8d:10"  -f packet.log  -o "arrival time" -all

        No.   arrival time         
        ----- -------------------- 
        0     1279597056.156951000 
        1     1279597056.159932000 
        2     1279597056.162929000 
        3     1279597056.165804000 
        4     1279597056.266433000 
        5     1279597056.376174000 

=head1 AUTHOR

Please report bugs sending E-mail E<lt>gmeng@aerohive.comE<gt>

Gengxiang Meng  E<lt>rossmeng@gmail.comE<gt>

=cut


