#!/usr/bin/perl -w
use strict;

use Pod::Usage;
use Data::Dumper;
use Getopt::Long;
use Time::Local 'timelocal_nocheck';

my $man = 0;
my $help = 0;
my $debug = 0;
my $literal = 0;

my $logfile = '';
my @patterns = ();
my $mode = '';

GetOptions(
	'h|?|help'  => \$help,
	'man'       => \$man,
    'debug|d'   => \$debug,
    'literal|l' => \$literal,
	'file|f=s'  => \$logfile,
    'pattern|p=s' => \@patterns,
    'mode|m=s'    => \$mode,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

die "Error, need specify log file\n" unless $logfile;
die "Error, need specify pattern(s)\n" unless @patterns;
die "Error, cannot support patterns more than two now\n" if(@patterns > 2); 
$mode = 'latest' unless $mode;

sub parse_time_str{
    my $file = shift;
    my @ps = @_;
    my @time_str = ();
    
    open(my $fh, "<", $file) or die "Cannot open file $file, $!";
    if (@ps == 1) {
        my $regexp = $literal ? qr/^(\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d).*\Q$ps[0]\E/
                              : qr/^(\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d).*$ps[0]/;
        while (<$fh>) {
            chomp;
            if (m/$regexp/i) {
                push @time_str, $1;
            }
        }
    }
    elsif(@ps == 2){
        my $rindex = 0;
        my @regexp_arr = $literal ?
        (
            qr/^(\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d).*\Q$ps[0]\E/,
            qr/^(\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d).*\Q$ps[1]\E/
        ) :
        (
            qr/^(\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d).*$ps[0]/,
            qr/^(\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d).*$ps[1]/
        );
        while (<$fh>) {
            chomp;
            my $regexp = $regexp_arr[$rindex];
            if (m/$regexp/i) {
                push @time_str, $1;
                $rindex ^= 1;
            }
        }
    }
    close $fh;
    return @time_str;
}

sub strtotime{
    my $str = shift;
    if($str =~ m/^(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)$/){
        return timelocal_nocheck($6, $5, $4, $3, $2, $1);
    }
    else{
        die "Error, cannot transfer string <$str> to time\n";
    }
}

sub calculate_interval{
    my ($stime1, $stime2) = @_;
    return abs(strtotime($stime1) - strtotime($stime2));
}

sub calculate_all_interval{
    my @t = @_;
    my @ti = ();
    
    my $index = 0;
    if (@patterns == 1) {
        do {
            push @ti, calculate_interval($t[$index], $t[++$index])
        }while(defined($t[$index + 1]))
    }
    else{
        do {
            push @ti, calculate_interval($t[$index], $t[++$index])
        }while(defined($t[++$index + 1]))
    }
    print Dumper(\@ti) if $debug;
    return @ti;
}

sub main{}

my @times = parse_time_str($logfile, @patterns);
print Dumper(\@times) if $debug;
die "Error, need more than two time to calculate interval\n" unless defined($times[1]);

if (@times == 2 || (@times == 3 && @patterns == 2)) {
    print calculate_interval($times[0], $times[1]), "\n";
    exit 0;
}

if ($mode =~ m/latest/i) {
    print calculate_interval($times[0], $times[1]), "\n";
}
elsif($mode =~ m/earliest/i){
    if (@patterns == 1) {
        print calculate_interval($times[$#times - 1], $times[$#times]), "\n";
    }
    else{
        my $index = $#times % 2 ? $#times : $#times - 1;
        print calculate_interval($times[$index - 1], $times[$index]), "\n";
    }
}
elsif($mode =~ m/max/i){
    my @intervals = calculate_all_interval(@times);
    my $max = $intervals[0];
    foreach my $i (@intervals){
        $max = $i if($i > $max);
    }
    print "$max\n";
}
elsif($mode =~ m/min/i){
    my @intervals = calculate_all_interval(@times);
    my $min = $intervals[0];
    foreach my $i (@intervals){
        $min = $i if($i < $min);
    }
    print "$min\n"
}
elsif($mode =~ m/average/i){
    my @intervals = calculate_all_interval(@times);
    my $sum = 0;
    foreach my $i (@intervals){
        $sum += $i
    }
    print int($sum / @intervals), "\n";
    
}

__END__

=head1 NAME

    get_log_interval.pl - Get the time interval of two log messages.

=head1 SYNOPSIS

    get_log_interval.pl [options]

=head1 OPTIONS

=over 8

=item B<-h|--help|-?>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-d|--debug>

Open debug mode and print more message.

=item B<-l|--literal>

Make the pattern string literal. In this case, you needn't care about escape characters.

=item B<-f|--file>

Specify the log file.

=item B<-p|--pattern>

Set the pattern string of log message. It will be treated as regular expression.

=item B<-m|--mode>

Set the mode of how to choose result from multi interval. It can be one of
"latest", "earliest", "max", "min", "average".


=back

=head1 DESCRIPTION

B<This program> will read the given log file and according to patterns to get
timestamps. And then return you a time interval according to mode.

=cut
