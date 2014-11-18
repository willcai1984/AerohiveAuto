#!/usr/bin/perl
#calculator the actual power£¨use current power -backoff power£©
use strict;
use warnings;
my $current_power=shift;
my $backoff_value=shift;
my $line;
$line =$current_power-$backoff_value;
print $line;



