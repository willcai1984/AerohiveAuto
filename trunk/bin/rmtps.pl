#!/usr/bin/perl -w
#----------------------------------------------------------------------
$norefresh=0;
# Change to
# $norefresh=1;
# to enable status caching
#----------------------------------------------------------------------

use LWP::UserAgent;
use HTTP::Status;
#----------------------------------------------------------------------
$version='4.0 (c) DLI 2006';
$type="lpc";
$prompt="UU> ";
$ua = LWP::UserAgent->new();
#----------------------------------------------------------------------

print STDERR "UserUtil $version\n\n";
my @junk = split( /\//, $0);
my $scriptFN = $junk[$#junk];
my $cmd;
if ($#ARGV <= 1)
    {
    print STDERR "Usage: $scriptFN <Host>[:port] <login:password> <[n]{on|off|pulse|status|interact}> ...\n";
    exit -1;
    }
($epc, $auth)=splice(@ARGV,0,2);
$base='http://'.$auth.'@'.$epc.'/';
print "Input Params: $base\n";
foreach (@ARGV)
    {
    $_=lc;
    if ($_ ne 'interact')
	{
	    $cmd=$_;
	    print ( "cmd = $_ \n");
	    cmd($cmd) && die "Unknown command $_\n";
	}
    else
	{
	print $prompt;
	while (<STDIN>)
	    {
	    s/\s+//g;
	    if ($_ eq "")
		{;}
	    elsif (($_ eq "?") || ($_ eq "help"))
		{print "Commands: {?|help} | [n]{on|off|pulse|status} | quit\n";}
	    elsif ($_ eq "quit")
		{last ;}
	    elsif (0==cmd($_))
	        {print "\t[OK]\n";}
	    else
		{print "\t[ERROR]\n";}
	    print $prompt;
	    }
	print "\n";
	}
    }

sub cmd
{
local ($_) = @_;
$_=lc;
s/(^[^1-8])/a$1/;
if (/^([1-8a])on$/)
    {
    ($type eq 'lpc' ) && RelLink('outlet?'.$1.'=ON') || RelLink('outleton?'.$1);
    }
elsif (/^([1-8a])off$/)
    {
    ($type eq 'lpc' ) && RelLink('outlet?'.$1.'=OFF') || RelLink('outletoff?'.$1);
    }
elsif (/^([1-8a])pulse$/)
    {
    ($type eq 'lpc' ) && RelLink('outlet?'.$1.'=CCL') || RelLink('outletgl?'.$1);
    }
elsif (/^([1-8a])status$/)
    {
    $n=$1;

    $norefresh && defined($response) && ($response->content =~/<td.*?>([1-8])<\/td>.*?<\/td>[^\/]*?\W(ON|OFF)\W/is) || RelLink('index.htm');
    $content=$response->content;

    ($type eq 'lpc') && ($content =~ /<a href=outleto/) && ($type='epc');

    while ($content =~ /<td.*?>([1-8])<\/td>[^<]*<td>([^<]*)<\/td>.*?<\/td>[^\/]*?\W(ON|OFF)\W/igs)
	{
	if (($1 eq $n) || ($n eq 'a'))
	    {
	    if ($3 eq "OFF")
	        {print $1," ON"," ",$2,"\n";}
	    else
	        {print $1," OFF"," ",$2,"\n";}
	    }
	}
    }
else
    {
    return(1);
    }
return(0);
}

sub RelLink
{
local ($_) = @_;
#print STDERR $base.$_,"\n";
$response = $ua->get($base.$_);
if ($response->is_error())
    {
    (($response->code != RC_NOT_FOUND) || ($type eq 'epc')) && die $response->status_line;
    $type='epc';
    return(0);
    }
return(1);
}
