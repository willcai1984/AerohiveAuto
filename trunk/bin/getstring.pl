#!/usr/bin/perl -w
# Filename: getstring.pl
# Name: Gengxiang Meng
# Description: this script is use to get a special string or value from a file
#---------------------------------------------------------------------------

use strict;
use warnings;
use Pod::Usage;
use Getopt::Long;
use FileHandle;

my ($rc, $msg);
my $FAIL=0;
my $PASS=1;
my $verbose = 0;
my $NOTDEFINED="undefined";
my $EXP_DELIMITER = "@";
my @keywords = ();

my %userinput = (
        "filename"=>$NOTDEFINED,
        "keyword"=>$NOTDEFINED,
        "first_key"=>$NOTDEFINED,
        "second_key"=>$NOTDEFINED,
        "position"=>0,
        "delimiter"=>=>$NOTDEFINED,
        "debug"=>0,
);

#-----------------------------------------------------------
# This routine is used to get a string or value from a file
#-----------------------------------------------------------
sub lookup_keyword {
        my $line;
        my ($rc, $msg);
        $rc = $FAIL;
        $msg = "Can't find what you want\n";

        if (!open LOGFILE, $userinput{filename}) {
                die "Can't open log file\n";
        }

        while (<LOGFILE>) {
                chomp;
                $line = $_;
                my @ret_value;
                my $match = 1;
                foreach my $keyword (@keywords) {  
                        if ($line !~ /$keyword/i) {
                                print "keyword $keyword NOT MATCH\n" if ($userinput{debug});
                                $match = 0;
                                last;
                        }
                }

                if ($match) {
                        print "===>>>>>$line, found match line\n" if ($userinput{debug});
                } else {
                        print "===>>>>>$line, skipped\n" if ($userinput{debug});
                        next;
                }
                
                
                $line =~ s/^$EXP_DELIMITER//;
                print "after pre-handle string:\n$line\n" if ($userinput{debug});

                if ($userinput{position} != 0) {
                  #use delimiter to split and return position value
                       if ($userinput{delimiter} =~ /$NOTDEFINED/) {
                              @ret_value = split /\s+/, $line;
                       } else {
                              @ret_value = split /$userinput{delimiter}/, $line;
                       }
                       if ($userinput{debug}) {
                              foreach my $value (@ret_value) {
                                      print "$value\n";
                              }
                       }

                       $msg = $ret_value[$userinput{position} - 1];
                       if (defined $ret_value[$userinput{position} - 1]) {
                              return ($PASS, $msg);
                       } else {
                              die "Nothing found in the position $userinput{position} via keyword ($userinput{keyword})\n";
                       }
                       print "$msg";
                } else {
                       $msg = $line;
                       $msg =~ s/.*$userinput{first_key}//;
                       $msg =~ s/$userinput{second_key}.*//;
                       return ($PASS, $msg);
                }
        }
        return ($rc, $msg);
}


MAIN:
my ($option_h, $option_man);

$rc = GetOptions(
        "help|h"=>\$option_h,
        "man"=>\$option_man,
        "f=s"=>\$userinput{filename},
        "k=s"=>sub { $userinput{keyword} = $_[1]; push (@keywords, $_[1]); },
        "k1=s"=>\$userinput{first_key},
        "k2=s"=>\$userinput{second_key},
        "p=i"=>\$userinput{position},
        "d=s"=>\$userinput{delimiter},
        "debug!"=>\$userinput{debug},
);

#-----------------------------------------
#print script usage syntax or man page
#-----------------------------------------

pod2usage(1) if ($option_h);
#print man usage
pod2usage(-verbose=>2) if ($option_man);

#------------------------------
#print Input parameters
#------------------------------

if ($userinput{debug}) {
        foreach my $key ( keys %userinput ) {
                print ("$key => $userinput{$key}\n") ;
        }
}

#----------------------------------------
# Input parameters check
#---------------------------------------

if (($userinput{filename} =~ /$NOTDEFINED/) || ($userinput{keyword} =~ /$NOTDEFINED/)) {
        print ("\n==>Error Missing Filename or Keyword String Defined\n\n");
        pod2usage(1);
        exit 1;
}

($rc, $msg) = lookup_keyword();
print "$msg\n";
if ($rc == $PASS) {
        exit 0;
} else {
        exit 1;
}

__END__

=pod

=head1 NAME

getstring.pl - Use To Get String From A File

=head1 SYNOPSIS

=over 12

=item B<getstring.pl>
[B<-help|h>]
[B<-man>]
[B<-f> I<log file name>]
[B<-k> I<keyword string>]
[B<-k1> I<The keyword string before the string that you want to find>]
[B<-k2> I<The keyword string after the string that you want to find>]
[B<-p> I<which column value you want>]
[B<-d> I<delimiter that separate target line>]
[B<-debug>]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-h>

Print a brief help message and exit.

=item B<-man>

Print a man page 

=item B<-f>

Name of the log file that you want to search via the keyword string

=item B<-k>

Keyword string that you want to match line that include the keyword content  in the input log file, you can use multiple keyword, their relationship are AND

=item B<-k1>

The keyword string before the string that you want to find

=item B<-k2>

The keyword string after the string that you want to find

=item B<-p>

the position of the target string locate in the line, for example, line= "1   default-profile                  1    0", we want the third column value then "-p 3"

=item B<-d>

What delimiter is use to separate the target line, default delimiter is space

=item B<-debug>

Print Debug message for engineer

=back

=head1 DESCRIPTION

B<getstring.pl> is used to get a special string a value from a file, you need provide keyword string to locate which line you want to find the target string or value, then specify some keyword or position to tell which string or value you want  to return


=head1 EXAMPLES

1. The following command is used to get a MAC address in log file /tmp/message.txt
         perl getstring.pl -f /tmp/message.txt -k "if=wifi0.1" -k1 "AA=" -k2 ";"
   Result:  0019:7703:fc90 


1. The following command is used to get a MAC address in log file /tmp/message.txt
         perl getstring.pl -f /tmp/message.txt -k "if=wifi0.1" -p 3 -d ";"
   Result:  AA=0019:7703:fc90

AH-03fc80#sh auth 
Authentication Entities:
if=interface; UID=User profile group ID; AA=Authenticator Address;
idx=index; PMK=Pairwise Master Key; PTK=Pairwise Transient Key;
GMK=Group Master Key; GTK=Group Transient Key;

if=wifi1.1; idx=14; AA=0019:7703:fca0; hive=hive0; default-UID=0;
PTK-rekey=0; GTK-rekey=0; GMK-rekey=0; strict=no; replay-window=0;
PPSK-enabled=no; default-PSK disabled=no; radius=disabled; method=unknown
PTK-timeout=4000; PTK-retry=4; GTK-timeout=4000; GTK-retry=4;
neighbor-connecting-threshold: -80 dBm; interval 1 minute
Local-cache-timeout=0
Protocol-suite=WPA-AES-PSK; PSK-CRC=f5;

No. Supplicant     UID PMK   PTK   Life  State   Reauth-itv Cipher   
--- -------------- --- ----- ----- ----- ------- ---------- ---------
0   0019:770e:5420 0   46f1* 5f73* -1    done    0          WPA/CCMP 
1   0019:7733:4470 0   46f1* 90e2* -1    done    0          WPA/CCMP 
2   0019:7706:cda0 0   46f1* 8240* -1    done    0          WPA/CCMP 
3   0019:770c:0b60 0   46f1* 6074* -1    done    0          WPA/CCMP 
4   0019:770e:5260 0   46f1* 08c8* -1    done    0          WPA/CCMP 
5   0019:7700:58e8 0   46f1* 9767* -1    done    0          WPA/CCMP 
6   0019:7700:03f8 0   46f1* 2aca* -1    done    0          WPA/CCMP 
7   0019:7700:2718 0   46f1* 4eae* -1    done    0          WPA/CCMP 
8   0019:770d:1460 0   46f1* 63f0* -1    done    0          WPA/CCMP 


if=wifi0.1; idx=13; AA=0019:7703:fc90; SSID=hzvm1tb4-ap340-1; default-UID=0;
Protocol-suite=open;


if=wifi0.2; idx=15; AA=0019:7703:fc91; SSID=xxx; default-UID=0;
PTK-rekey=0; GTK-rekey=0; GMK-rekey=0; strict=no; preauth=no; replay-window=0;
PPSK-enabled=no; default-PSK disabled=no; radius=disabled; method=unknown
PTK-timeout=4000; PTK-retry=4; GTK-timeout=4000; GTK-retry=4;
local-TKIP-counter-measure=enabled; remote-TKIP-counter-measure=enabled;
Local-cache-timeout=86400
Protocol-suite=PSK-auto; PSK-CRC=f1;

Total CWP station entries = 0

No. Supplicant     Interface Flag Client-IP        Translated-IP
--- -------------- --------- ---- ---------------  ---------------


3. The following command is used to get a last line second MAC address in log file /tmp/message.txt
         perl getstring.pl -f /tmp/message.txt -k "0025:869b:a421" -p 2
   Result:  0019:770c:29c0


AH-0c29c0# QAPROMPT detect  
show route
Route table:
flag: (S)tatic, (I)nterface (L)ocal (T)unnel (O)wn
sta             nhop            oif      metric upid flag
---------------------------------------------------------
0000:0000:0000  0019:7704:b2a0  wifi1.1   224    0      

0019:770c:29e0  0019:770c:29c0  wifi1.1     0 4096  IL  

0019:770c:29d0  0019:770c:29c0  wifi0.1     0 4096  IL  

0019:770c:29c0  0019:770c:29c0  eth0        0 4096  IL  

0019:770c:29c1  0019:770c:29c0  eth1        0 4096  IL  

0019:770c:29c2  0019:770c:29c0  red0        0 4096  IL  

0019:770c:29c3  0019:770c:29c0  agg0        0 4096  IL  

0019:7704:b2a0  0019:7704:b2a0  wifi1.1   224 4096      

0019:7704:b280  0019:7704:b2a0  wifi1.1   224 4096     

0025:869b:a421  0019:770c:29c0  eth0        0    2   L  



=head1 AUTHOR

Please report bugs sending E-mail E<lt>gmeng@aerohive.comE<gt>

Gengxiang Meng  E<lt>rossmeng@gmail.comE<gt>

=cut

