#!/usr/bin/perl -w
#-------------------------------------------------------------------
# Please report bug to hcheng@aerohive.com
#--------------------------------------------------------------------

use strict;
use Pod::Usage;
use diagnostics;
use Getopt::Long;


my $man        = 0;
my $help       = 0;
my $debug      = 0;
my $ignorecase = 0;
my $file       = '';
my @mlines     = ();
my $interval   = 0;

GetOptions(
           'h|?|help' => \$help,
           'man'      => \$man,
           'f=s'      => \$file,
           'i=i'      => \$interval,
           'd'        => \$debug,
           'c'        => \$ignorecase,
           'l=s'      => \@mlines,   
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

#option sanity check
if($file eq ''){
	print "Error = Please specify a file\n";
	exit 1
}

if($interval < 0){
    print "Error = Interval must be a positive integer or 0\n";
    exit 1;
}

if($#mlines < 1){
    print "Error = Please specify two or more lines\n";
    exit 1;
}


my @lines_num  = ();
my $line_index = 0;

open(FILE, "<", $file)
  or die "Error = Cannot open file $file: $!";
while(<FILE>){
    last unless defined($mlines[$line_index]);
    my $p = $mlines[$line_index];
    $p = $ignorecase ? qr/$p/i : qr/$p/;
    if(m/$p/){
        print "Find the ", ($line_index + 1), "th pattern line at line $.\n" if $debug;
        push @lines_num, $.;
        $line_index++;
    }
}

if($#lines_num != $#mlines){
    print "Cannot find the ", ($line_index + 1), "th pattern line\n";
    print "Cannot find all the pattern lines\n" if $debug;
    exit 1;
}elsif($interval == 0){
    print "Find all the pattern lines\n" if $debug;
    exit 0;
}

my $num_index = 0;
while($num_index <= $#lines_num){
    if($num_index == 0){
        $num_index++;
        next;
    }
    if(($lines_num[$num_index] - $lines_num[$num_index - 1]) != $interval){
        print "The ", ($num_index + 1), "th pattern line is not at the right place\n"
          if $debug;
        exit 1;
    }else{
        $num_index++;
    }
}

print "Find all the pattern lines\n" if $debug;
exit 0;

__END__

=head1 NAME

mlinesearch.pl - This is a tool to find multi-lines from log file and these
lines must appear orderly in log file .Different from searchoperation.pl
which only match a single line, though you can set multi-patterns, but these
one must appear in one line.

=head1 SYNOPSIS

    mlinesearch.pl [options]
    Options:
    -help            brief help message
    -man             full documentation
    -f               file name
    -l               line match pattern
    -i               interval of lines
    -d               open debug
    -c               case insensitive
    
=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-f>

Specify a file to look for the pattern lines.

=item B<-l>

Specify line patterns. you need to use ' instead of " as these patterns are regular expression.

=item B<-i>

Specify line interval. The default value is 0 which means do not care interval.

=back

=head1 DESCRIPTION

=cut
