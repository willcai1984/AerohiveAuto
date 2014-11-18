#!/usr/bin/perl -w

use strict;
use Expect;
use Getopt::Long;

my $help = 0;
my $man = 0;
my $conserver = '';
my $coname = '';
my $angle = 0;
my $rate = 15;

GetOptions(
    'help|?'      => \$help,
	man           => \$man,
    'conserver=s' => \$conserver,
    'coname=s'    => \$coname,
    'angle=i'     => \$angle,
    'rate=s'      => \$rate,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

die "Error, Need specify console server IP or domain!\n" unless $conserver;
die "Error, Need specify console name of device!\n" unless $coname;

$angle = ($angle == 0) ? '00' : ($angle * 10);

my $timeout = int($angle/10/$rate) + int(360/$rate) + 5;
print "Timeout: $timeout\n";

my $cmd = "console -M $conserver $coname -f";
my $exp = Expect->spawn($cmd) or die "Cannot spawn $cmd, $!\n";
sleep 1;
$exp->log_stdout(0);
$exp->clear_accum();
$exp->send_slow(1, '@00#');
#use @Q# to wake up console is not reliable now
#$exp->send_slow(1, '@Q#');
my $zero = 0;
$exp->expect(
    $timeout,
    [
        qr/#/,
        sub {
            my $fh = shift;
            my $before = $fh->before();
            if($before =~ m/\@PASS/i){
                print "Command excute OK!\n";
                exit 0;
            }
            if($zero && $before =~ m/\@ZERO/i){
                print "Return to ZERO!\n";
                exit 0;
            }
            if($before =~ m/\@ERRO/i){
                print "Error command sent!\n";
                exit 2;
            }
            if($before =~ m/\@COM_TIME_OUT/i){
                print "Command timeout!\n";
                exit 3;
            }
            print "Connect OK!\n";
            $fh->send_slow(1, "\@$angle#");
            sleep 1;
            $zero = 1;
            exp_continue();
        }
    ],
    [
        'timeout',
        sub {
            print "Timeout reached!  -->  command timeout\n";
            exit 1;
        }
    ],
);

END {
    $exp->clear_accum();
    $exp->hard_close();
}

