#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description:
# This script is used to parse IP from ifconfig log file
#--------------------------------

use strict;
use warnings;
use diagnostics;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use XML::Simple;
use Data::Dumper;
use Log::Log4perl;
use Expect;
use POSIX ':signal_h';
my $OUTPUTLOG_SIZE = 40 * 1024;

my $NO_FILE      = "No File specified";
my $ON           = 1;
my $OFF          = 0;
my $PASS         = 1;
my $FAIL         = 0;
my $SETUP_IF_TMO = 5 * 60;                # 5 minutes
my $NOFUNCTION   = "Nofunction";
my $NOTDEFINED   = "not_defined";
my @junk         = split( /\//, $0 );
@junk = split( '\.', $junk[$#junk] );
my $scriptFn = $junk[0];
my $USER     = "root,password";
my $DSL      = "dsl";
my $DHCP     = "dhcp";
my $ETHER    = "ethernet";
my $COAX     = "hspn";
my $OS_LINUX = "lin";
my $OS_MAC   = "mac";
my $OS_WIN   = "win";
my $OS_AERO  = "aero";

#-----<<<----------------

my %userInput = (
	"debug"      => "0",
	"scriptname" => $scriptFn,
	"logdir"     => $NOTDEFINED,
	"filename"   => $NOTDEFINED,
	"interface"  => $NOTDEFINED,
	"inputfile"  => $NOTDEFINED,
	"winif"      => 1,
	"user"       => "root",
	"dutip"      => "127.0.0.1",
	"cmd"        => $NOTDEFINED,
	"pwd"        => "password",
	"screenoff"  => 0,
	"logoff"     => 0,
	"port"       => {},
	"operating"  => $OS_LINUX,
	"hwaddr"     => 0,
	"subnet"     => 0,

	#    "commands"=>["ifconfig -a | grep -e Link -e \"inet addr:\""],
	"commands"                    => [ "ifconfig -a ", "exit" ],
	"errtable"                    => [],
	"insert"                      => [],
	"timeout"                     => "100",
	"uppercase"                   => 0,
	"hwaddr_delimiter_dash"       => 0,
	"hwaddr_style_five_delimiter" => 0,
	"noipmask"                    => 0,
);

#---------------------------------------------------------
# This routine is used to initialize the log feature
#---------------------------------------------------------
sub initLogger {
	my ( $profFile, $junk ) = @_;
	my $rc  = $PASS;
	my $rc2 = $PASS;
	my $msg = "Successfully Set Logger";

	#--------------------
	# initialize logger
	#---------------------
	my $temp        = $profFile->{scriptname};
	my $localLog    = $profFile->{logdir} . "/$temp.log";
	my $localLog2   = $profFile->{logdir} . "/$temp\2.log";
	my $clobberLog  = $profFile->{logdir} . "/$temp\_clobber.log";
	my $clobberLog2 = $profFile->{logdir} . "/$temp\_clobber2.log";
	if ( -e $localLog ) {
		$temp = -s "$localLog";
		if ( $temp > $OUTPUTLOG_SIZE ) {
			$rc2 = `mv -f $localLog $localLog2`;
		}
	}
	if ( -e $clobberLog ) {
		$temp = -s $clobberLog;
		if ( $temp > $OUTPUTLOG_SIZE ) {
			$rc2 = `mv -f $clobberLog $clobberLog2`;
		}
	}

# layout: date-module + line mumber -(info,debug,warn,error,fatal)> message +  new line
	my $layout =
	  Log::Log4perl::Layout::PatternLayout->new("%d--%F{1}:%L--%M--%p> %m%n");
	my $gName = "initLogger";
	if ( defined $profFile->{gcov}{$gName} ) {
		$profFile->{gcov}{$gName} += 1;
	}
	else {
		$profFile->{gcov}{$gName} = 1;
	}

	$profFile->{logger} = Log::Log4perl->get_logger();
	$profFile->{logger}->level("0");

	if ( $profFile->{screenoff} == $OFF ) {
		my $screen =
		  Log::Log4perl::Appender->new( "Log::Log4perl::Appender::Screen",
			stderr => 0 );
		$profFile->{logger}->add_appender($screen);
	}
	if ( $profFile->{logoff} == $OFF ) {
		my $appender = Log::Log4perl::Appender->new(
			"Log::Log4perl::Appender::File",
			filename => $localLog,
			mode     => "append"
		);
		my $writer = Log::Log4perl::Appender->new(
			"Log::Log4perl::Appender::File",
			filename => $clobberLog,
			mode     => "clobber"
		);
		$appender->layout($layout);
		$profFile->{logger}->add_appender($appender);
		$profFile->{logger}->add_appender($writer);
	}
	$profFile->{logger}->info("--> Log initialized <--")
	  if ( $profFile->{debug} > 2 );
	return ( $rc, $msg );
}

#-------------------------------------------
# Get name
#-------------------------------------------
sub getBaseName {
	my ( $path, $junk ) = @_;
	my @t1;
	@t1 = split( "/", $path );
	$junk = $t1[$#t1];
	return ($junk);
}

#-------------------------------------------------------
#--------------------------------------------------------
sub accessRmtHost {
	my ($profFile) = @_;
	my $tmo        = $profFile->{timeout};
	my $temp       = 0;
	my $rc         = $PASS;
	my $rc2;
	my $index;
	my $errindex;
	my $errsize;
	my $errkey;
	my $limit;
	my $log     = $profFile->{logger};
	my $cmd     = "";
	my $user    = $profFile->{user};
	my $pwd     = $profFile->{pwd};
	my $server  = $profFile->{dutip};
	my $testLog = $profFile->{inputfile};
	my @buff;
	my $junk;
	my $try = 0;
	( $server, $junk ) = split( '\/', $server );
	$limit = @{ $profFile->{commands} };
	$junk  = system("touch $testLog");
	$log->info("NUMBER OF CMD= $limit") if ( $profFile->{debug} > 2 );

	for ( $index = 0 ; $index < $limit ; $index++ ) {
		$cmd = $cmd . $profFile->{commands}[$index] . " ; ";
	}
	if ( $limit > 0 ) {
		$cmd = "ssh $user\@$server " . " \"$cmd\" > $testLog ";
	}
	else {
		$cmd = "ssh $user\@$server " . " \"echo NULL \" > $testLog ";
	}
	my $msg = "executeCmdProcess: successfully execute $cmd";

	$log->info("stepCmdProcess: cmd($cmd) ") if ( $profFile->{debug} > 2 );
	if ( $profFile->{noprint} ) {
		$log->info("stepCmdProcess with TMO($tmo):cmd($cmd)");
	}
	my $exp = Expect->spawn("$cmd");

	#turn off output into terminal
	$exp->log_stdout(0) if ( !$profFile->{debug} );
	$limit = 4;
	if ( defined $exp ) {
		while ( $try < $limit ) {
			$exp->expect(
				$tmo,
				[
					timeout => sub {
						$log->info("stepCmdExecute:$cmd is TimeOUT ");
						$rc  = $FAIL;         #failed
						$try = 10;
						$msg = " TIMEOUT ";
						return;
					  }
				],
				[
					"Connection refused",
					sub {
						my $fh = shift;
						$rc  = $FAIL;
						$try = 11;
						$msg = " CONNECTION REFUSED";
						$log->info("$msg");
						return;
					  }
				],
				[
					"Are you sure you want to continue connecting (yes/no)?",
					sub {
						my $fh = shift;

						#			      print (" SSH \n ====== \n");
						$fh->send("yes\n");
						$try = 1;
						sleep 2;
					  }
				],
				[
					"[P|p]assword:*",
					sub {
						my $fh = shift;
						$try++;
						if ( $try >= $limit ) {
							$try = 12;
							$rc  = $FAIL;
							$msg = "UNKNOWN PASSWORD($pwd)";
							return;
						}
						$fh->send("$pwd\n");
						$try = 12;      # 3
						$rc  = $PASS;
					  }
				],
				[
					eof => sub {

						#			       $log->info ("==>EOF \n");
						$rc  = $PASS;
						$try = 12;
					  }
				],
			);
		}

		if ( $rc == $PASS ) {
			$exp->expect(
				$tmo,
				[
					timeout => sub {
						$log->info("stepCmdExecute:$cmd is TimeOUT ");
						$rc  = $FAIL;         #failed
						$try = 10;
						$msg = " TIMEOUT ";
						return;
					  }
				],
				[
					eof => sub {

						#			       $log->info ("==>EOF \n");
						$rc  = $PASS;
						$try = 12;
					  }
				],
			);

		}

		#$log->info ("==>try($try) \n");
		if ( $rc == $FAIL ) {
			$msg = "Failed to execute $cmd due to $msg";
		}
		else {
			$rc  = $PASS;
			$msg = "Successfully execute ($try)--  $cmd";
		}

	}
	return ( $rc, $msg );
}

#-------------------------------------------
# convermask
#-------------------------------------------
sub convertmask {
	my ($mask) = shift;
	my @buff = split( '\.', $mask );
	my $lim = $#buff;
	my ( $index, $i, $result, $lmask );
	return ($mask) if ( $lim < 2 );
	$lmask = 0;
	for ( $index = 0 ; $index <= $lim ; $index++ ) {
		$result = $buff[$index];
		for ( $i = 0 ; $i < 8 ; $i++ ) {
			if ( $result & 0x1 ) {
				$lmask++;
			}
			$result = $result >> 1;
		}
	}
	return ($lmask);
}

#-------------------------------------------
# convermask
#-------------------------------------------
sub convertMacMask {
	my ($mask) = shift;
	my ( $index, $i, $result, $lmask );
	$lmask  = 0;
	$result = hex($mask);
	for ( $i = 0 ; $i < 32 ; $i++ ) {
		if ( $result & 0x1 ) {
			$lmask++;
		}
		$result = $result >> 1;
	}
	return ($lmask);
}

#-------------------------------------------
# Extract Host IP
#-------------------------------------------
sub extractHostIp {
	my ( $profFile, $junk ) = @_;
	my $rc     = $PASS;
	my $osType = lc( $profFile->{operating} );
	my $msg    = "Successfully Set up WAN interface ";
	my $log    = $profFile->{logger};
  SWITCH_OSTYPE: for ($osType) {
		/$OS_LINUX/ && do {
			( $rc, $msg ) = extractLinuxHostIp($profFile);
			last;
		};
		/$OS_MAC/ && do {
			( $rc, $msg ) = extractMacHostIp($profFile);
			last;
		};
		/$OS_WIN/ && do {
			( $rc, $msg ) = extractWinHostIp($profFile);
			last;
		};
		/$OS_AERO/ && do {
			( $rc, $msg ) = extractAeroHostIp($profFile);
			last;
		};
		$rc  = $FAIL;
		$msg = "Error_OS_$osType\_is_not_supported";
		last;
	}
	$msg =~ s/\/.*$// if $userInput{subnet};
	return ( $rc, $msg );
}

#-------------------------------------------
# Extract LINUX Host IP
#-------------------------------------------
sub extractLinuxHostIp {
	my ( $profFile, $junk ) = @_;
	my $rc  = $PASS;
	my $msg = "Successfully_get_Linux_IF";
	my $log = $profFile->{logger};
	my ( $index, $i, $line );
	my $inputfile = $profFile->{inputfile};
	my $dut       = $profFile->{dutip};
	my $user      = $profFile->{user};
	my $pwd       = $profFile->{pwd};
	my $ptr       = \%{ $profFile->{port} };
	my ( @junk, @junk2, $temp, $key );
	my $curEntry;
	open( INPUT, "<$inputfile" ) or die("Error:Could not open $inputfile ");
	my @buff = <INPUT>;
	close INPUT;
	my $start = 0;
	my $ifname = "";
	
	for ( $index = 0 ; $index <= $#buff ; $index++ ) {
		$line = $buff[$index];
		$line =~ s/\n//g;
		$line =~ s/\@//;
		next if ( $line =~ /^\s*$/ );
		if ($line =~ m/^\s+ether /) {
			my @tmparr = split(" ", $line);
			$ptr->{$ifname}{hwaddr} = uc $tmparr[1];
		}
		
		if ( $line =~ /Link encap:/ || $line =~ /flags=/ ) {
			$log->info("start=0=>line:$line") if ( $profFile->{debug} > 1 );
			if ( $start == 1 ) {
				if ( defined $curEntry ) {

					#initial with fake IP
					$curEntry->{ipaddr} = "127.8.8.8 ";
					$curEntry->{mask}   = 24;
				}
			}
			$start                     = 1;
			@junk                      = split( " ", $line );
			$ifname = $junk[0];
			$ifname =~ s/://;
			$ptr->{ $ifname }{hwaddr} = $junk[$#junk];
			if ( $line =~ /hwaddr\b/i ) {
				$ptr->{ $ifname }{hwaddr} = $junk[$#junk];
			}
			$curEntry = \%{ $ptr->{ $ifname } };
		}
		if ( $start == 1 ) {
			$log->info("start=1=>line:$line") if ( $profFile->{debug} > 1 );
			if ( $line =~ /inet addr:/ ) {
				if ( !( defined $curEntry ) ) {
					$msg = "Error: internal error curEntry is not defined";
					$rc  = $FAIL;
					return ( $rc, $msg );
				}
				$start = 0;
				@junk = split( " ", $line );
				for ( $i = 0 ; $i <= $#junk ; $i++ ) {

					# get ip address
					$log->info("start=1=>junk($i):$junk[$i]")
					  if ( $profFile->{debug} > 1 );
					if ( $junk[$i] =~ /^addr:/i ) {
						@junk2 = split( ":", $junk[$i] );
						$curEntry->{ipaddr} = $junk2[1];
					}

					# get Mask
					if ( $junk[$i] =~ /^mask:/i ) {
						@junk2 = split( ":", $junk[$i] );

						#convert to number bit mask
						$junk2[1] = convertmask( $junk2[1] );
						$curEntry->{mask} = $junk2[1];
					}
				}
				#$curEntry = "";
			}    # end of if (inet address)
			elsif ( $line =~ m/inet / ){
				if (!(defined $curEntry)) {
					$msg = "Error: internal error curEntry is not defined";
					$rc  = $FAIL;
					return ( $rc, $msg );
				}
				$start = 0;
				@junk = split(" ", $line);
				$curEntry->{ipaddr} = $junk[1];
				$curEntry->{mask} = convertmask($junk[3]);
			}
		}
	}
	$msg = "0.0.0.0";
	$ptr = \%{ $profFile->{port} };
	$log->info("result:STARTING to grep interface $profFile->{interface} info ")
	  if ( $profFile->{debug} > 1 );
	foreach $key ( keys %{$ptr} ) {
		$log->info("result:compare $profFile->{interface} and $key")
		  if ( $profFile->{debug} > 1 );
		if ( $profFile->{interface} eq $key ) {
			if ( $profFile->{hwaddr} ) {
				$msg = $ptr->{$key}{hwaddr};
			}
			else {
				if ( defined $ptr->{$key}{ipaddr} ) {
					$msg = $ptr->{$key}{ipaddr} . "/$ptr->{$key}{mask}";
				}
				else {
					$msg = "127.8.8.8/24";
					$msg = "0.0.0.0/24";
				}
			}
			$log->info("result:$msg") if ( $profFile->{debug} > 1 );
			last;
		}
	}
	$rc = $PASS;
	if ( $msg =~ /0\.0\.0\.0/ ) {
		$rc = $FAIL;
	}
	if ( $profFile->{debug} > 2 ) {
		$temp = Dumper($ptr);
		$log->info($temp);
	}
	return ( $rc, $msg );
}

#-------------------------------------------
# Extract MAC Host IP
#-------------------------------------------
sub extractMacHostIp {
	my ( $profFile, $junk ) = @_;
	my $rc  = $PASS;
	my $msg = "Successfully_get_MAC_IF";
	my $log = $profFile->{logger};
	my ( $index, $i, $line );
	my $inputfile = $profFile->{inputfile};
	my $dut       = $profFile->{dutip};
	my $user      = $profFile->{user};
	my $pwd       = $profFile->{pwd};
	my $ptr       = \%{ $profFile->{port} };
	my ( @junk, $temp, $key );
	my $curEntry;
	open( INPUT, "<$inputfile" ) or die("Error:Could not open $inputfile ");
	my @buff = <INPUT>;
	close INPUT;
	my $start = 0;

	for ( $index = 0 ; $index <= $#buff ; $index++ ) {
		$line = $buff[$index];
		$line =~ s/\n//g;
		$line =~ s/\@//;
		next if ( $line =~ /^\s*$/ );
		if ( $line =~ /flags=/ ) {
			$log->info("start=0=>line:$line") if ( $profFile->{debug} > 1 );
			if ( $start == 1 ) {
				if ( defined $curEntry ) {

					#initial with fake IP
					$curEntry->{ipaddr} = "127.8.8.8 ";
					$curEntry->{mask}   = 24;
				}
			}
			$start = 1;
			@junk = split( ":", $line );

			#just temporarely initialize the pointer
			$ptr->{ $junk[0] }{hwaddr} = $line;
			$curEntry = \%{ $ptr->{ $junk[0] } };
		}
		if ( $start == 1 ) {
			$log->info("start=1=>line:$line") if ( $profFile->{debug} > 1 );
			if ( $line =~ /inet\b/ ) {
				if ( !( defined $curEntry ) ) {
					$msg = "Error: internal error curEntry is not defined";
					$rc  = $FAIL;
					return ( $rc, $msg );
				}

				#	inet 10.16.133.112 netmask 0xffffff00 broadcast 10.16.133.255
				@junk = split( " ", $line );
				$log->info("start=1=>inet=$junk[1];mask=$junk[3]")
				  if ( $profFile->{debug} > 1 );
				$curEntry->{ipaddr} = $junk[1];

				#convert to Decimal
				$curEntry->{mask} = convertMacMask( $junk[3] );
			}    # end of if (inet address)
			if ( $line =~ /ether / ) {
				if ( !( defined $curEntry ) ) {
					$msg = "Error: internal error curEntry is not defined";
					$rc  = $FAIL;
					return ( $rc, $msg );
				}
				@junk = split( " ", $line );
				$curEntry->{hwaddr} = $junk[$#junk];
			}

			# Reset the pointer
			if ( $line =~ /supported media:/ ) {
				if ( !( defined $curEntry ) ) {
					$msg = "Error: internal error curEntry is not defined";
					$rc  = $FAIL;
					return ( $rc, $msg );
				}
				$start    = 0;
				$curEntry = "";
			}
		}
	}
	$msg = "0.0.0.0";
	$ptr = \%{ $profFile->{port} };
	$log->info("result:STARTING to grep interface $profFile->{interface} info ")
	  if ( $profFile->{debug} > 1 );
	foreach $key ( keys %{$ptr} ) {
		$log->info("result:compare $profFile->{interface} and $key")
		  if ( $profFile->{debug} > 1 );
		if ( $profFile->{interface} eq $key ) {
			if ( $profFile->{hwaddr} ) {
				$msg = $ptr->{$key}{hwaddr};
			}
			else {
				if ( defined $ptr->{$key}{ipaddr} ) {
					$msg = $ptr->{$key}{ipaddr} . "/$ptr->{$key}{mask}";
				}
				else {
					$msg = "127.8.8.8/24";
				}
			}
			$log->info("result:$msg") if ( $profFile->{debug} > 1 );
			last;
		}
	}
	$rc = $PASS;
	if ( $msg =~ /"0.0.0.0"/ ) {
		$rc = $FAIL;
	}
	if ( $profFile->{debug} > 2 ) {
		$temp = Dumper($ptr);
		$log->info($temp);
	}
	return ( $rc, $msg );
}

#-------------------------------------------
# Extract Windows Host IP
#-------------------------------------------
sub extractWinHostIp {
	my ( $profFile, $junk ) = @_;
	my $rc  = $PASS;
	my $msg = "Successfully_get_MAC_IF";
	my $log = $profFile->{logger};
	my ( $index, $i, $line );
	my $inputfile = $profFile->{inputfile};
	my $dut       = $profFile->{dutip};
	my $user      = $profFile->{user};
	my $pwd       = $profFile->{pwd};
	my $ptr       = \%{ $profFile->{port} };
	my ( @junk, $temp, $key, $currIndex, $currkey );
	my $curEntry;
	open( INPUT, "<$inputfile" ) or die("Error:Could not open $inputfile ");
	my @buff = <INPUT>;
	close INPUT;
	my $start        = 0;
	my $ethcount     = 0;
	my $wireless_cnt = 0;
	my $tunnel_cnt   = 0;

	for ( $index = 0 ; $index <= $#buff ; $index++ ) {
		$line = $buff[$index];
		$line =~ s/\n//g;
		$line =~ s/\@//;
		next if ( $line =~ /^[|\@]\s*$/ );

		$log->info("start=0=>line:$line") if ( $profFile->{debug} > 1 );
		if (
			( $line =~ /adapter/ )
			&& (   ( $line =~ /^Tunnel .*/ )
				|| ( $line =~ /^Ethernet .*/ )
				|| ( $line =~ /^Wireless .*/ ) )
		  )
		{
			$start    = 1;
			$curEntry = "";
			@junk     = split( " ", $line );

			#just temporarely initialize the pointer
			$junk[0] = lc $junk[0];
			$log->info("start=1=>$junk[0],line:$line")
			  if ( $profFile->{debug} > 1 );
			$currIndex = $junk[0];
			if ( $currIndex =~ /^wireless/ ) {
				$wireless_cnt++;
				$currIndex = $junk[0] . "_$wireless_cnt";
				print "wirelesscnt=$wireless_cnt index=$currIndex\n"
				  if ( $profFile->{debug} > 1 );
			}
			elsif ( $currIndex =~ /^ethernet/ ) {
				$ethcount++;
				$currIndex = $junk[0] . "_$ethcount";
				print "ethcount=$ethcount index=$currIndex\n"
				  if ( $profFile->{debug} > 1 );
			}
			else {
				$tunnel_cnt++;
				$currIndex = $junk[0] . "_$tunnel_cnt";
				print "tunnel_cnt=$tunnel_cnt index=$currIndex\n"
				  if ( $profFile->{debug} > 1 );
			}
			$ptr->{$currIndex}{hwaddr} = $line;
			$curEntry                  = \%{ $ptr->{$currIndex} };
			$curEntry->{ipaddr}        = "0.0.0.0 ";
			$curEntry->{mask}          = 32;
			next;
		}
		if ( $start == 1 ) {
			$log->info("start=2,$ethcount=>line:$line")
			  if ( $profFile->{debug} > 1 );
			if ( $line =~ /IP.* Address/ ) {
				$log->info("start=2,$ethcount=>IPV4 address:$line")
				  if ( $profFile->{debug} > 1 );
				if ( !( defined $curEntry ) ) {
					$msg = "Error: internal error curEntry is not defined";
					$rc  = $FAIL;
					return ( $rc, $msg );
				}
				@junk = split( ":", $line );
				$log->info("IPADDRE  = start=1=>inet=$junk[1]")
				  if ( $profFile->{debug} > 1 );
				$junk[0] = $junk[1];
				$temp = $junk[1];
				if ( $junk[0] =~ /\(/ ) {
					@junk = split( '\(', $temp );
				}
				$log->info("IPADDRE   TESTING $junk[0]")
				  if ( $profFile->{debug} > 1 );

				$curEntry->{ipaddr} = $junk[0];
				$curEntry->{ipaddr} =~ s/\s//g;
			}    # end of if (ipv4 address)

			if ( $line =~ /Subnet Mask/ ) {
				$log->info("start=2=>SUBNET:$line")
				  if ( $profFile->{debug} > 1 );
				if ( !( defined $curEntry ) ) {
					$msg = "Error: internal error curEntry is not defined";
					$rc  = $FAIL;
					return ( $rc, $msg );
				}
				@junk = split( ":", $line );
				$log->info("MASK start=1=>inet=$junk[1]")
				  if ( $profFile->{debug} > 1 );

				#convert to Decimal
				$curEntry->{mask} = convertmask( $junk[1] );
			}    # end of if (mask )
			if ( $line =~ /Physical Address/ ) {
				$log->info("start=2=>Physical:$line")
				  if ( $profFile->{debug} > 1 );
				if ( !( defined $curEntry ) ) {
					$msg = "Error: internal error curEntry is not defined";
					$rc  = $FAIL;
					return ( $rc, $msg );
				}
				@junk = split( ":", $line );
				$curEntry->{hwaddr} = $junk[$#junk];
				$curEntry->{hwaddr} =~ s/-/:/g;
				$curEntry->{hwaddr} =~ s/\s//g;

			}
		}
	}
	$msg = "0.0.0.0";
	$ptr = \%{ $profFile->{port} };
	$log->info("result:STARTING to grep interface $profFile->{interface} info ")
	  if ( $profFile->{debug} > 1 );
	foreach $key ( keys %{$ptr} ) {
		$log->info("result:compare $profFile->{interface} and $key")
		  if ( $profFile->{debug} > 1 );
		$currkey = $profFile->{interface} . "_" . $profFile->{winif};

		#	if ( $profFile->{interface} =~ /$key/i ) {
		if ( $currkey =~ /$key/i ) {
			if ( $profFile->{hwaddr} ) {
				$msg = $ptr->{$key}{hwaddr};
			}
			else {
				if ( defined $ptr->{$key}{ipaddr} ) {
					$msg = $ptr->{$key}{ipaddr} . "/$ptr->{$key}{mask}";
				}
				else {
					$msg = "127.8.8.8/24";
					$msg = "0.0.0.0/24";
				}
			}
			$log->info("result:$msg") if ( $profFile->{debug} > 1 );
			last;
		}
	}
	$rc = $PASS;
	if ( $msg =~ /0\.0\.0\.0/ ) {
		$rc = $FAIL;
	}
	if ( $profFile->{debug} > 2 ) {
		$temp = Dumper($ptr);
		$log->info($temp);
	}
	return ( $rc, $msg );
}

#-------------------------------------------
# Extract MAC Host IP
#-------------------------------------------
sub extractAeroHostIp {
	my ( $profFile, $junk ) = @_;
	my $rc  = $PASS;
	my $msg = "Successfully_get_MAC_IF";
	my $log = $profFile->{logger};
	my ( $index, $i, $line );
	my $inputfile = $profFile->{inputfile};
	my $dut       = $profFile->{dutip};
	my $user      = $profFile->{user};
	my $pwd       = $profFile->{pwd};
	my $ptr       = \%{ $profFile->{port} };
	my ( $var1, $var2 );
	my ( @junk, $temp, $key );
	my $curEntry;
	open( INPUT, "<$inputfile" ) or die("Error:Could not open $inputfile ");
	my @buff = <INPUT>;
	close INPUT;
	my $start = 0;

	for ( $index = 0 ; $index <= $#buff ; $index++ ) {
		$line = $buff[$index];
		$line =~ s/\n//g;
		$line =~ s/\@/>/g;
		next if ( $line =~ /^\s*$/ );
		$log->info("         XXXXX=>line:$line") if ( $profFile->{debug} > 1 );
		if ( $line =~ /AH-.*interface/i ) {
			$log->info("start=0=>line:$line") if ( $profFile->{debug} > 1 );
			if ( $start == 1 ) {
				if ( defined $curEntry ) {

					#initial with fake IP
					$curEntry->{ipaddr} = "0.0.0.0 ";
					$curEntry->{mask}   = 32;
				}
			}
			else {
				$start = 1;
				@junk = split( " ", $line );

				#just temporarely initialize the pointer
				# use last word ifname as hash key
				$ptr->{ $junk[$#junk] }{hwaddr} = $line;
				$curEntry                       = \%{ $ptr->{ $junk[$#junk] } };
				$curEntry->{ipaddr}             = "127.7.7.7";
				$curEntry->{mask}               = 24;
			}
			next;
		}
		if ( $start == 1 ) {
			$log->info("start=1=>line:$line") if ( $profFile->{debug} > 1 );
			if ( $line =~ /IP addr=/ ) {
				if ( !( defined $curEntry ) ) {
					$msg = "Error: internal error curEntry is not defined";
					$rc  = $FAIL;
					return ( $rc, $msg );
				}
				( $var1, $var2 ) = split( ";", $line );
				$log->info("start=2=>inet=$var1 ----     mask=$var2")
				  if ( $profFile->{debug} > 1 );
				@junk = split( "=", $var1 );
				$log->info("start=3=>junk0=$junk[0] ----- junk1=$junk[1]")
				  if ( $profFile->{debug} > 1 );
				$curEntry->{ipaddr} = $junk[1];

				#convert to Decimal

				@junk = split( "=", $var2 );
				$log->info("start=4=>junk0=$junk[0] ----- junk1=$junk[1]")
				  if ( $profFile->{debug} > 1 );
				$curEntry->{mask} = convertmask( $junk[1] );
			}    # end of ( IP addr)
			if ( $line =~ /MAC addr=/i ) {
				if ( !( defined $curEntry ) ) {
					$msg = "Error: internal error curEntry is not defined";
					$rc  = $FAIL;
					return ( $rc, $msg );
				}
				( $var1, $var2 ) = split( ";", $line );
				@junk = split( "=", $var1 );
				$log->info("start=5=>MAC =$junk[1]")
				  if ( $profFile->{debug} > 1 );
				$curEntry->{hwaddr} = $junk[1];
			}

			# Reset the pointer
			if ( $line =~ /Rx bytes=/ ) {
				if ( !( defined $curEntry ) ) {
					$msg = "Error: internal error curEntry is not defined";
					$rc  = $FAIL;
					return ( $rc, $msg );
				}
				$log->info("start=6=> Reset") if ( $profFile->{debug} > 1 );
				$start    = 0;
				$curEntry = "";
			}
		}
	}
	$msg = "0.0.0.0";
	$ptr = \%{ $profFile->{port} };
	$log->info("result:STARTING to grep interface $profFile->{interface} info ")
	  if ( $profFile->{debug} > 1 );
	foreach $key ( keys %{$ptr} ) {
		$log->info("result:compare $profFile->{interface} and $key")
		  if ( $profFile->{debug} > 1 );
		#if ( $profFile->{interface} eq $key ) {
			if ( $profFile->{hwaddr} ) {
				$msg = $ptr->{$key}{hwaddr};
			}
			else {
				if ( defined $ptr->{$key}{ipaddr} ) {
					$msg = $ptr->{$key}{ipaddr} . "/$ptr->{$key}{mask}";
				}
				else {
					$msg = "127.8.8.8/24";
					$msg = "0.0.0.0/24";
				}
			}
			$log->info("result:$msg") if ( $profFile->{debug} > 1 );
			last;
		#}
	}
	$rc = $PASS;
	if ( $msg =~ /0\.0\.0\.0/ ) {
		$rc = $FAIL;
	}
	if ( $profFile->{debug} > 2 ) {
		$temp = Dumper($ptr);
		$log->info($temp);
	}
	return ( $rc, $msg );
}

#
#-------------------------------------------------------------
# adjust output mac address format, enhance by Gengxiang Meng
#-------------------------------------------------------------
sub format_output_mac_addr {
	my @mac_buffer;
	my $newmsg;
	my $delimiter = ":";
	my $style     = 2;

	($newmsg) = @_;
	if ( !$userInput{hwaddr} ) {
		if ( $userInput{noipmask} ) {
			($newmsg) = split /\//, $newmsg;
		}
		return $newmsg;
	}

	if ( $userInput{hwaddr_delimiter_dash} ) {
		$delimiter = "-";
	}
	if ( $userInput{hwaddr_style_five_delimiter} ) {
		$style = 4;
	}

	@mac_buffer = split /:|-/, $newmsg;
	$newmsg = join "", @mac_buffer;

	@mac_buffer = $newmsg =~ /\w{$style}/g;

	$newmsg = join $delimiter, @mac_buffer;

	if ( $userInput{uppercase} ) {
		$newmsg = uc $newmsg;
	}

	return $newmsg;
}

#************************************************************
# Main Routine
#************************************************************
MAIN:
my $exp;
my $TRUE  = 1;
my $FALSE = 0;
my @userTemp;
my ( $x, $h );
my $option_h;
my $rc = 0;
my ( $len, $len1 );
my $temp;
my $msg;
my $key;
my $logdir;
my $TESTSUITE_VERSION = "1.0";
my @commands          = ();
my $globalRc          = 0;
my $option_man        = 0;
my $junk              = 0;
my $value;
$rc = GetOptions(
	"x=s"        => \$userInput{debug},
	"help|h"     => \$option_h,
	"man"        => \$option_man,
	"l=s"        => \$userInput{logdir},
	"d=s"        => \$userInput{dutip},
	"f=s"        => \$userInput{inputfile},
	"m"          => \$userInput{hwaddr},
	"s"          => \$userInput{subnet},
	"n=s"        => \$userInput{winif},
	"o=s"        => \$userInput{operating},
	"u=s"        => \$userInput{user},
	"p=s"        => \$userInput{pwd},
	"i=s"        => \$userInput{interface},
	"uppercase!" => \$userInput{uppercase},
	"c=s"        => \$userInput{cmd},
	"v=s"        => sub {
		if ( exists $commands[0] ) { push( @commands, $_[1] ); }
		else                       { $commands[0] = $_[1]; }
	},
	"dash!"   => \$userInput{hwaddr_delimiter_dash},
	"width!"  => \$userInput{hwaddr_style_five_delimiter},
	"nomask!" => \$userInput{noipmask},
);

#Using pod2usage to display Help or Man
pod2usage(1) if ($option_h);
pod2usage( -verbose => 2 ) if ($option_man);
my $dir = $userInput{logdir};
if ( $dir =~ /$NOTDEFINED/ ) {
	$dir = `pwd`;
	$dir =~ s/\n//;
	$userInput{logdir} = $dir;
}
printf("DIR = $dir \n") if ( $userInput{debug} > 1 );

#---------------------------------------------
# Initialize Logger
#---------------------------------------------
( $rc, $msg ) = initLogger( \%userInput, );
if ( $rc != 1 ) {
	printf("RC$rc $msg\n");
	exit 1;
}

#printf("--------------- Input Parameters  ---------------\n") if $userInput{debug} ;
$junk = " ";
$temp = Dumper( \%userInput );
$userInput{logger}->info(
	"------------------ $scriptFn  Input Parameters  ------------------\n$temp")
  if ( $userInput{debug} > 1 );

my $limit = @commands;
my $line;
if ( $limit > -1 ) {
	$junk = " ";
	foreach $line (@commands) {
		$junk .= "-v $line ";
	}
}
$junk = $userInput{scriptname} . ".pl -l " . $userInput{logdir} . $junk;

#$userInput{interface} = lc $userInput{interface} ;
my $inputfile = $userInput{inputfile};
if ( $userInput{inputfile} =~ /$NOTDEFINED/ ) {
	$temp                 = "getrmtip_expect";
	$inputfile            = $dir . "/$temp\.log";
	$userInput{inputfile} = $inputfile;
	( $rc, $msg ) = accessRmtHost( \%userInput );
	if ( $rc == $FAIL ) {

		#    print ("Failed:$msg");
		exit(1);
	}
	$userInput{logger}->info("Setup WAN interface Log  is saved in $inputfile")
	  if ( $userInput{debug} > 1 );
}
( $rc, $msg ) = extractHostIp( \%userInput );

$userInput{logger}->info("$msg") if ( $userInput{debug} > 1 );

$msg = format_output_mac_addr($msg);
print $msg;

if ( $rc == $FAIL ) {
	$userInput{logger}->info("==> $userInput{scriptname}  failed")
	  if ( $userInput{debug} > 1 );
	exit(1);
}
$userInput{logger}->info("==> $userInput{scriptname} passed")
  if ( $userInput{debug} > 1 );

exit(0);
1;
__END__

=pod

=head1 NAME

getrmtip.pl - This is a utility to get a remote Linux/MAC/Windows Ip based on
              the interface name. This utility is working with Remote Host
			  having ssh enable and execution without prompt. Beside it could
			  parse the input file which has the result in Linux/MAC ifconfig
			  format and Windows ipconfig/Aerohive "show interface" format.

=head1 SYNOPSIS

=over 12

=item B<getrmtip.pl>
[B<-help|-h>]
[B<-man>]
[B<-l> I<log file path>]
[B<-d> I<DUT IP >]
[B<-i> I<(eth0|wlan0|eth0:1)|(en0|en1)|(Wireless|Ethernet)|(eth0|eth1|wifi0|wifi1)>]
[B<-m> I<to request MAC address>]
[B<-n> I<index interface for windows>]
[B<-o> I<linux|mac|windows|aerohive>]
[B<-u> I<DUT logon userid>]
[B<-p> I<DUT logon password >]
[B<-x> I<debug level>]
[B<-f> I<Input file>]
[B<-dash> I<enable output mac address with delimiter "-">]
[B<-width> I<enable output mac address with five delimiter style>]
[B<-nomask> I<don't output netmask value>]
[B<-uppercase> I<output mac address with uppercase>]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-l >

Redirect stdout to the /path/getrmtip.log

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)

=item B<-d>

DUT IP address.

=item B<-u>

DUT login userid.

=item B<-p>

DUT password userid.

=item B<-o>

Specific operating system MAC/Linux/Windows/HiveOS. By default, OS is Linux

=item B<-i>

Select WAN Interface eth0|eth2_rename|eth1:10 for Linux or en0|en1 for MAC or Wireless|Ethernet for Windows or (eth0|eth1|wifi0|wifi1) for Aerohive.

=item B<-f>

Input file which contain the format of ifconfig output. getrmtip.pl will search the output file and get the matching interface and return the ip/MAC

=item B<-n>

Select the index interface for windows

=item B<-m>

Select the MAC address need to be searched instead of IP address

=item B<-s>

Select subnet add to the IP address

=item B<-dash>

Enable output mac address with delimiter dash "-"

=item B<-width>

Enable output mac address with two delimiter style

=item B<-nomask>

Disable output netmask, only output IP address when user what a IP address

=item B<-uppercase>

output mac address with uppercase, default we keep the original format.

=back

=head1 EXAMPLES

1. The following command is used to get eth0 ip address from remote Linux host 

perl getrmtip.pl -d 10.1.10.1 -u root -p password -i eth0  

2. The following command is used to get en0 MAC address from remote MAC host 

perl getrmtip.pl -o mac -d 10.1.10.1 -u root -p password -i en0

3. The following command is used to get  MAC en0 ip address from file contains ifconfig format 

perl getrmtip.pl -f ifconfig.log  -i en0 -o mac

4. The following command is used to get Windows Wireless ip from file contains ipconfig format 

perl getrmtip.pl -f ipconfig.log  -i Wireless -o win(dows)

5. The following command is used to get Aerohive wifi0 mac address from file contains "show interface" format 

perl getrmtip.pl -f aerohive.log  -i wifi0 -o aero(hive) -m -dash -width

6. The following command is used to get Windows second Wireless ip from file contains ipconfig format

perl getrmtip.pl -f ipconfig.log  -i Wireless -o win(dows) -n 2


=head1 AUTHOR

Please report bugs using L<http://budz/>

JoeNguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut

