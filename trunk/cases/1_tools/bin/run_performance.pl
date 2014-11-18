#!/usr/bin/perl -w
use strict;

use DBI;
use Expect;
use threads;
use Pod::Usage;
use Data::Dumper;
use Getopt::Long;
use Net::SSH::Expect;
use Array::Average;
use File::Basename;
use File::Temp qw/tempfile/;

#do not modify these vars arbitrary
my $conn_ap_cmd = 'console -M 10.155.40.200 ap -f';
my $db_host = '10.155.40.200';
my $db_name = 'performance';
my $db_user = 'perf';
my $db_passwd = 'aerohive';
my $run_tst_time = 60;
my $runtst_timeout = $run_tst_time + 20;
my $dbh;
my $aph;
my $sta_mac;
my $ssid;

#get value from Getopt::Long
my %opt = (
    'man'        => 0,
    'help'       => 0,
    'server'     => '',
    'rlogdir'    => '',
    'logdir'     => '',
    'aptype'     => '',
    'apip'       => '',
    'sta'        => '',
    'os'         => '',
    'nic'        => '',
    'linkmode'   => '',
    'angle'      => 0,
    'distance'   => 5,
    'encrypt'    => '',
    'terminal'   => '',
    'runtstimes' => 10,
    'timeprefix' => '',
    'jobid'      => '',
    'imgname'    => '',
    'connectap'  => '',
    'debug'      => 0,
);

#table Run
my %Run = (
    'APType'     => '',
    'Radio'      => '',
    'Channel'    => '',
    'LinkMode'   => '',
    'Throughput' => 0,
    'RSSI'       => 0,
    'APConfID'   => 0,
    'StaConfID'  => 0,
    'TSTConfID'  => 0,
    'JobID'      => 0,
    'Image'      => 0, 
);
#table APConf
my %APConf = (
    'APType'      => '',
    'CountryCode' => 0,
    'Power'       => 0,
    'Encryption'  => '',
    'Angle'       => 0,
    'Distance'    => 0,
);
#table TSTConf
my %TSTConf = (
    'Protocol' => '',
    'Script'   => '',
);
#table StaConf
my %StaConf = (
    'OSType'       => '',
    'WifiCardType' => '',
);
#table RunDetail
my %RunDetail = (
    'RunID'      => 0,
    'Throughput' => 0,
    'RSSI'       => 0,
    'APlog'      => '',
    'ResultCSV'  => '',
    'Runlog'     => '',
);
#table APImage
my %APImage = (
    'Version'    => '',
    'BuildTime'  => '',
    'BuildBy'    => '',
    'Type'       => '',
    'RunByDaily' => '',
);

sub strtime{
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
    $mon += 1;
    return "$year-$mon-$mday-$hour-$min";
}

sub connect_ap{
    my $exp = Expect->spawn($conn_ap_cmd) or die "Cannot spawn $conn_ap_cmd, $!\n";
    sleep 2;
    #$aph->log_file("/home/expect.log", "w");
    $exp->log_stdout(0);
    #$exp->debug(2);
    #wake up console
    $exp->send("\n");
    $exp->clear_accum();

    $exp->expect(
        10,
        [
            qr/login:/i,
            sub {
                my $self =  shift;
                $self->send("admin\n");
                exp_continue();
            }
        ],
        [
            qr/Password:/i,
            sub {
                my $self = shift;
                $self->send("aerohive\n");
                exp_continue();
            }
        ],
        [
            qr/AH-.*#/i,
            sub {
                my $self = shift;
                $self->send("\n");
            }
        ],
        [
            'timeout',
            sub {
                my $self = shift;
                print "Timeout reached!  -->  Login timeout\n";
            }
        ]
    );
    print "Connect AP OK!\n" if $opt{'debug'};
    return $exp;
}

sub sendcli{
    my ($ap, $cli, $log, $lastime, $stop) = @_;
    
    print "CLI: $cli, LOG: $log\n" if $opt{'debug'};
    print "Lastime: $lastime\n" if($opt{'debug'} && defined $lastime);
    print "Stop: $stop\n" if($opt{'debug'} && defined $stop);
    
    my $timeout = defined($lastime) ? ($lastime + 10) : 10;
    
    $ap->clear_accum();
    $ap->log_file($log, "w");

    $ap->expect(
        $timeout,
        [
            qr/login:/i,
            sub {
                #print "match login\n";
                my $self =  shift;
                $self->send("admin\n");
                exp_continue();
            }
        ],
        [
            qr/Password:/i,
            sub {
                #print "match password\n";
                my $self = shift;
                $self->send("aerohive\n");
                exp_continue();
            }
        ],
        [
            qr/AH-.*#/i,
            sub {
                print "match prompt\n";
                my $self = shift;
                $self->send("$cli\n");
                if(defined $lastime){
                    sleep $lastime;
                    if(defined $stop){
                        print "Stop the output!\n";
                        $self->send("\cC");
                    }
                    #$self->send("\cC") if defined($stop);
                }
                #flush the cli output to logfile
                $self->send_slow(1, "\n");
            }
        ],
        [
            'timeout',
            sub {
                print "Timeout reached!  -->  $cli\n";
            }
        ]
    );
    #sometime CLI output will be write into next file, so sleep to wait and clear_accum
    sleep 1;
    $ap->clear_accum();
    $ap->log_file(undef);
}

#parse mac of station and ssid from "show station";
sub get_sta_mac_ssid{
    my $con = shift @_;
    
    my ($fh, $fname) = tempfile();
    my $sta_mac = '';
    my $ssid = '';
    
    #sleep two second to wait for show station result, try to fix bug that show
    #station will not get station info sometimes
    sendcli($con, "show station", $fname, 2);
    my $gotssid = 0;
    while(<$fh>){
        if(!$gotssid || m/SSID=(.*):/){
            $ssid = $1;
            $gotssid = 1;
            next;
        }
        if($_ =~ m/(\w+:\w+:\w+)\s+192\.168/){
            $sta_mac = $1;
            last;
        }
    }
    close $fh;
    unlink $fname unless $opt{'debug'};
    print "sta_mac: $sta_mac\nSSID: $ssid\n" if $opt{'debug'};
    return ($sta_mac, $ssid);
}

#parse value from ap
sub parse_show_run{
    my $con = shift @_;
    
    my ($fh, $fname) = tempfile();
    
    sendcli($con, "show run", $fname);
    while(<$fh>){
        $Run{'Radio'} = $1 if(m/interface (wifi\d) ssid /);
        $Run{'Channel'} = $1 if(m/interface wifi\d radio channel (\d+)/);
        $APConf{'Power'} = $1 if(m/interface wifi\d radio power (\d+)/);
    }
    close $fh,
    unlink $fname unless $opt{'debug'};
}

sub set_apconf{
    my $con = shift @_;
    
    my ($fh, $fname) = tempfile();
    
    $APConf{'APType'} = $opt{'aptype'};
    sendcli($con, "show boot-param", $fname); 
    while(<$fh>){
        $APConf{'CountryCode'} = $1 if(m/Country Code: *(\d+)/);
    }
    #$APConf{'Power'} is set by parse_show_run
    $APConf{'Encryption'} = $opt{'encrypt'};
    $APConf{'Angle'} = $opt{'angle'};
    $APConf{'Distance'} = $opt{'distance'};
    close $fh;
    unlink $fname unless $opt{'debug'};
}

sub parse_script_by_name{
    my $basename = basename(lc($opt{'script'}));
    my @arr = split /[_\.]/, $basename;
    warn "file name error\n" if $arr[3] !~ m/tst/;
    print Dumper(\@arr);
    $Run{'LinkMode'} = $arr[0];
    $TSTConf{'Protocol'} = $arr[1];
    $TSTConf{'Script'} = $arr[2];
}

sub set_staconf{
    $StaConf{'OSType'} = $opt{'os'};
    $StaConf{'WifiCardType'} = $opt{'nic'};
}

sub get_staconf{
    my $staip = shift @_;
    my $ssh = Net::SSH::Expect->new(
        host => $staip,
        user => 'root',
        password => 'aerohive',
    );
    my $timeout = $ssh->timeout();
    $ssh->timeout(15);
    $ssh->login();
    $ssh->timeout($timeout);
    
    my $uname = $ssh->exec('uname');
    if($uname =~ m/linux/i){
        print "OSType: Linux\n" if opt{'debug'};
        $StaConf{'OSType'} = 'Linux';
        my $lspci = $ssh->exec('lspci');
        if($lspci =~ m/Network +controller: +(.*)/i){
            $StaConf{'WifiCardType'} = $1;
            print "WifiCardType: $1" if opt{'debug'};
        }
    }elsif($uname =~ m/CYGWIN_NT/i){
        print "OSType: Windows\n" if opt{'debug'};
        $StaConf{'OSType'} = 'Windows';
        my $ipconfig = $ssh->exec('ipconfig /all');
        my @arr = split /\n/, $ipconfig;
        #print Dumper(\@arr);
        my $find = 0;
        foreach my $line (@arr){
            if($find){
                if($line =~ m/Description[ .]*: *(.*)/i){
                    $StaConf{'WifiCardType'} = $1;
                    print "wifiCardType: $1\n" if $opt{'debug'};
                    last;
                }
            }else{
                if($line =~ m/Wireless Network Connection/i){
                    $find = 1;
                }
            }
        }
    }elsif($uname =~ m/Darwin/i){
        print "OSType: MacOS\n" if opt{'debug'};
        $StaConf{'OSType'} = 'MacOS';
        my $airport = $ssh->exec('system_profiler SPAirPortDataType');
        if($airport =~ m/Firmware Version: +(.*)/i){
            $StaConf{'WifiCardType'} = $1;
            print "WifiCardType: $1" if opt{'debug'};
        }
    }
}

sub set_apimage{
    my $con = shift @_;
    
    my ($fh, $fname) = tempfile();
    
    sendcli($con, "show version detail", $fname);
    while(<$fh>){
        s/^\s*//;
        s/\s*$//;
        if(m/Current *version: *(.*)/i){
            $APImage{'Version'} = $1;
            next;
        }
        if(m/Build *time: *(.*)/i){
            $APImage{'BuildTime'} = $1;
            next;
        }
        if(m/Build *by: *(.*)/i){
            $APImage{'BuildBy'} = $1;
            last;
        }
    }
    close $fh;
    unlink $fname unless $opt{'debug'};
    
    if($opt{'imgname'} =~ m/\.img\.S/){
        $APImage{'Type'} = 'release';
    }
    elsif($opt{'imgname'} =~ m/_daily\.img/){
        $APImage{'Type'} = 'daily';
    }
    elsif($APImage{'BuildBy'} =~ m/buildmaster/i){
        $APImage{'Type'} = 'official';
    }
    else{
        $APImage{'Type'} = 'private';
    }   
}

sub connect_db{
    my $dsn = "DBI:mysql:database=$db_name;host=$db_host;mysql_read_default_group=client";
    $dbh = DBI->connect($dsn, $db_user, $db_passwd,
                        {'RaiseError' => 1}
                        );
    if (!$dbh) {
        die "Can't connect to $dsn: $!";
    }
    print "Connect DB OK!\n";
}

#insert data into RunDetail
sub insert_rundetail{
    my $columns = join ",", keys %RunDetail;
    my $values = join ",", map {"'$_'"} values %RunDetail;
    my $insert = "INSERT INTO RunDetail ($columns) VALUES ($values)";
    print "$insert\n" if $opt{'debug'};
    $dbh->do($insert) or die $dbh->errstr;;
}

#get id from table APConf, TSTConf, StaConf, APImage
sub get_table_id{
    my ($dbh, $name, %table) = @_;
    my $restrict = 'WHERE ';
    my @tmp = ();
    foreach my $key (keys %table){
        next if $key eq 'ID';
        push @tmp, "$key='$table{$key}'";
    }
    $restrict .= join(" AND ", @tmp);
    my @row_ary = $dbh->selectrow_array("SELECT ID FROM $name $restrict");
    
    return $row_ary[0] if defined $row_ary[0];
    
    my $insert = "INSERT INTO $name SET " . join(",", @tmp);
    print "$insert\n" if $opt{'debug'};
    $dbh->do($insert) or die $dbh->errstr;
    my $id = $dbh->last_insert_id(undef, undef, $name, 'ID');
    return $id;
}

sub update_run{
    my ($dbh, $id) = @_;
    
    my @tmp = ();
    foreach my $key (keys %Run){
        push @tmp, "$key='$Run{$key}'";
    }
    my $update = "UPDATE Run SET " . join(",", @tmp) . ",EndTime=NOW()" . " WHERE ID='$id'";
    print "$update\n" if $opt{'debug'};
    $dbh->do($update) or die $dbh->errstr;
}

sub send_file_to_server{
    my ($local, $remote) = @_;
    
    print "send file \"$local\" to chariot server: \"$remote\"\n" if $opt{'debug'};
    my $send_file = 'staf local fs copy file \"' . $local . '\" tofile \"' .
                   $remote . '\" tomachine ' . $opt{'server'};
    print "STAF: $send_file\n" if $opt{'debug'};
    my $send = `$send_file`;
    print "$send\n" if $opt{'debug'};
    #sleep 1 sencond to wait something, This is IMPORTANT
    sleep 1;
    die "Cannot send file to remote server!\n"
        unless $send =~ m/^Response/i;
}

sub get_file_from_server{
    my ($remote, $local) = @_;
    my $get_file = "staf $opt{'server'} " . 'fs copy file \"' . $remote . '\" tofile \"' .
                   $local . '\" tomachine 10.155.40.200';
    print "STAF: $get_file\n" if $opt{'debug'};
    my $get = `$get_file`;
    print "$get\n" if $opt{'debug'};
    #sleep 1 sencond to wait something, This is IMPORTANT
    sleep 1;
    die "Cannot get file from server!\n" 
        unless $get =~ m/^Response/i;
}

#run cmd on remote, need check return code
sub stafcmd{
    my ($target, $cmd, $runlog) = @_;
    my $staf = '';
    if(defined $runlog){
        $staf = "staf \"$target\" process start shell command \"$cmd\" stdout \"$runlog\" wait";
    }else{
        $staf = "staf \"$target\" process start shell command \"$cmd\" wait";
    }
    #staf 10.155.35.52 process start shell command "runtst \"D:\performance\downlink.tst\" \"D:\performance\result_hcheng.tst\" -t 60" stdout "D:\hcheng.log" wait returnstdout stderrtostdout
    print "STAF: $staf\n" if $opt{'debug'};
    my $run = `$staf`;
    print "$run\n" if $opt{'debug'};
    die "Run remote command failed!\nTarget: $target\nCMD: $cmd\n"
        unless $run =~ m/Return *Code: *0/i;
}

sub sendcli_ap{
    #my ($cli, $log, $prompt) = @_;
    my %param = @_;
    my $cli = defined($param{'cli'}) ? $param{'cli'} : '';
    my $log = defined($param{'log'}) ? $param{'log'} : '/dev/null';
    my $pmt = defined($param{'prompt'}) ? $param{'prompt'} : 'AH.*#';
    my $tmo = defined($param{'timeout'}) ? $param{'timeout'} : 10;
    my $cmd = "/opt/auto_main/bin/clicfg.pl -i 782 -o $tmo -d localhost -e ap " .
              "-u admin -p aerohive -m \'$pmt\' -n -z $log -l ./" .
              " -v \'$cli\'";
    `$cmd`;
}

sub run_tst{
    my ($cmd, $log) = @_;
    sleep 2;
    stafcmd($opt{'server'}, $cmd, $log);
    sleep 2;
}

sub log_ap{
    my ($con, $smac, $log) = @_;
    my $tmplog_1 = "/tmp/perf_1.log";
    my $tmplog_2 = "/tmp/perf_2.log";
    my $tmplog_3 = "/tmp/perf_3.log";
    
    sendcli($con, "clear interface $Run{'Radio'} counter", "/dev/null");
    sendcli($con, "clear ssid $ssid counter station", "/dev/null");
    sleep 1;
    
    sendcli($con, "show station $smac", $tmplog_1, ($run_tst_time + 25), 1);
    sendcli($con, "show interface $Run{'Radio'} counter", $tmplog_2, 2);
    sendcli($con, "show system ath $Run{'Radio'}", $tmplog_3, 5);
    #sendcli_ap(cli => "show station $smac", timeout => 190, log => $tmplog_1);
    #sendcli_ap(cli => 'ctrl-c', prompt => '.*');
    #sendcli_ap(cli => "show interface $Run{'Radio'} counter", log => $tmplog_2);
    #sendcli_ap(cli => "show system ath $Run{'Radio'}", log => $tmplog_3);
    
    `cat $tmplog_1 >> $log`;
    `cat $tmplog_2 >> $log`;
    `cat $tmplog_3 >> $log`;  
}

sub parse_rssi{
    my $aplog = shift @_;
    my @rssi = ();
    my $base = '0';
    
    open LOG, "<", $aplog;
    while(<LOG>){
        if(m{\s+(-\d+)\((\d+)\)}){
            my @arr = split / +/, $_;
            if(defined($arr[4]) && ($arr[4] ne $base)){
                push @rssi, $2;
                $base = $arr[4];
            }
            #print Dumper(\@arr);
            #last;
        }
    }
    close LOG;
    print Dumper(\@rssi);
    if($#rssi < 7){
        warn "too few data to calculate RSSI average(< 7)!\n";
        return 0;
    }else{
        @rssi = sort { $a <=> $b } @rssi;
        return sprintf("%0.f", average(@rssi[2 .. $#rssi - 2]));
    }
}

sub parse_throughput{
    my $csv = shift @_;
    my $thrput = 0;
    
    open CSV, "<", $csv;
    while(<CSV>){
        next unless m/All Pairs/i;
        chomp;
        my @tmp = split /,/;
        $thrput = defined($tmp[9]) ? $tmp[9] : 0;
        last;
    }
    close CSV;
    
    return $thrput;
}

sub check_connection{
    my $staip = shift @_;
    my $ssh = Net::SSH::Expect->new(
        host => $staip,
        user => 'root',
        password => 'aerohive',
    );
    #my $timeout = $ssh->timeout();
    #$ssh->timeout(15);
    $ssh->login();
    #$ssh->timeout($timeout);
    my $ping = ($StaConf{'OSType'} eq 'Windows') ?
                "ping $opt{'apip'} -c 4" : "ping -c 4 $opt{'apip'}";
    #check ping from client to ap
    my $rc = $ssh->exec($ping);
    #print Dumper($rc);
    if($rc =~ m/from .* ttl=/){
        print "Client is on AP\n";
    }
    else{
        print "Client is not on AP, Reconnect\n";
        $ssh->send('networksetup -setairportpower en1 off');
        $ssh->send('networksetup -setairportpower en1 on');
        $ssh->send($opt{'connectap'});
        #check reconnect ok
        sleep 5;
        $rc = $ssh->exec($ping);
        if($rc =~ m/from .* ttl=/){
            print "Reconnect OK\n";
        }
        else{
            die "Cannot connect to AP\n";
        }
    }
    $ssh->close();
}

#-------MAIN-------
GetOptions(
           'help|?'       => \$opt{'help'},
           'man'          => \$opt{'man'},
           'server=s'     => \$opt{'server'},
           'rlogdir=s'    => \$opt{'rlogdir'},
           'logdir=s'     => \$opt{'logdir'},
           'aptype=s'     => \$opt{'aptype'},
           'apip=s'       => \$opt{'apip'},
           'station=s'    => \$opt{'sta'},
           'ostype=s'     => \$opt{'os'},
           'nictype=s'    => \$opt{'nic'},
           'script=s'     => \$opt{'script'},
           'angle=i'      => \$opt{'angle'},
           'distance=s'   => \$opt{'distance'},
           'encrypt=s'    => \$opt{'encrypt'},
           'terminal=s'   => \$opt{'terminal'},
           'runtstimes=i' => \$opt{'runtstimes'},
           'timeprefix=s' => \$opt{'timeprefix'},
           'jobid=s'      => \$opt{'jobid'},
           'imgname=s'    => \$opt{'imgname'},
           'connectap=s'  => \$opt{'connectap'},
           'debug'        => \$opt{'debug'},
) or pod2usage(2);

pod2usage(1) if $opt{'help'};
pod2usage(-exitstatus => 0, -verbose => 2) if $opt{'man'};

print "Options:\n", Dumper(\%opt) if $opt{'debug'};
#runtstimes should be 1-10
die "Error, runtstimes should be 1-10!\n"
    if(($opt{'runtstimes'} < 1) or ($opt{'runtstimes'} > 10));

my @thrput = ();
my @RSSI = ();

$aph = connect_ap();
connect_db();
($sta_mac, $ssid) = get_sta_mac_ssid($aph);
parse_show_run($aph);
set_apconf($aph);
parse_script_by_name();
set_staconf();
set_apimage($aph);
$aph->clear_accum();
$aph->hard_close();
sleep 2;

#clear ap counter info
#sendcli("clear interface $Run{'Radio'} counter", "/dev/null");
#sendcli("clear ssid $ssid counter station", "/dev/null");
#sleep 2;
    
my $prefix = $opt{'timeprefix'};
my $remote_working_dir = "$opt{'rlogdir'}/$prefix";
my $remote_script_file = "$remote_working_dir/". basename($opt{'script'});
stafcmd($opt{'server'}, 'mkdir \"' . $remote_working_dir . '\"');
send_file_to_server($opt{'script'}, $remote_script_file);
    
#start run performance and create a record in Run
$dbh->do("INSERT INTO Run SET StartTime=NOW()") or die $dbh->errstr;
my $runid = $dbh->last_insert_id(undef, undef, 'Run', 'ID');

foreach my $index (1..$opt{'runtstimes'}){
    my $conn = connect_ap();
    my $result_tst = "$remote_working_dir/$prefix-result_$index.tst";
    my $runtst_log = "$remote_working_dir/$prefix-result_$index.log";
    my $runtst = "runtst $remote_script_file $result_tst -t $runtst_timeout";
    my $aplog = "$opt{'logdir'}". "/$prefix-ap_$index.log";
    
    my $pid = fork();
    if(!defined($pid)){
        die "Error, Cannot fork, $!";
    }
    if($pid == 0){
        print "In child process\n";
        run_tst($runtst, $runtst_log);
        exit 0;
    }else{
        print "In parent process\n";
        log_ap($conn, $sta_mac, $aplog);
    }
    
    #my $thread1 = threads->new(\&log_ap, $conn, $sta_mac, $aplog);
    #my $thread2 = threads->new(\&run_tst, $runtst, $runtst_log);
    #
    #$thread2->join;
    #$thread1->join;  
    
    wait();
    $conn->clear_accum();
    $conn->hard_close();
    check_connection($opt{'sta'});
    sleep 5;
    
    #generate csv file
    my $result_csv = "$remote_working_dir/$prefix-result_$index.csv";
    my $fmttst = "fmttst -v $result_tst $result_csv";
    stafcmd($opt{'server'}, $fmttst);
    
    #transfer files from chariot server to mpc
    $RunDetail{'APlog'} = $aplog;
    $RunDetail{'ResultCSV'} = "$opt{'logdir'}". "/$prefix-result_$index.csv";
    $RunDetail{'Runlog'} = "$opt{'logdir'}". "/$prefix-result_$index.log";
    get_file_from_server($result_csv, $RunDetail{'ResultCSV'});
    get_file_from_server($runtst_log, $RunDetail{'Runlog'});
    
    $RunDetail{'RunID'} = $runid;
    if(-e $RunDetail{'ResultCSV'}){
        $RunDetail{'Throughput'} = parse_throughput($RunDetail{'ResultCSV'});
        push @thrput, $RunDetail{'Throughput'};
    }else{
        die "Error: cannot find result csv file!\n";
    }
    
    if(-e $RunDetail{'APlog'}){
        $RunDetail{'RSSI'} = parse_rssi($RunDetail{'APlog'});
        push @RSSI, $RunDetail{'RSSI'};
    }else{
        die "Error: cannot find ap log!\n";
    }
    connect_db();
    sleep 1;
    insert_rundetail();
    sleep 10;
}

connect_db();
#die "Error: data incomplete!\n" unless $#thrput == 9;
print Dumper(\@thrput);
print Dumper(\@RSSI);
@thrput = grep { $_ != 0 } @thrput;
@RSSI = grep { $_ != 0 } @RSSI;
$Run{'Throughput'} = average(@thrput);
$Run{'RSSI'} = average(@RSSI);
$Run{'APType'} = $opt{'aptype'};
$Run{'APConfID'} = get_table_id($dbh, 'APConf', %APConf);
$Run{'StaConfID'} = get_table_id($dbh, 'StaConf', %StaConf);
$Run{'TSTConfID'} = get_table_id($dbh, 'TSTConf', %TSTConf);
$Run{'JobID'} = $opt{'jobid'};
$Run{'Image'} = get_table_id($dbh, 'APImage', %APImage);

update_run($dbh, $runid);

print "OK and Over!\n";

#release Expect handle
#relase DBI handle
END {
    $dbh->disconnect();
    $aph->clear_accum();
    $aph->hard_close();
}

__END__

=head1 NAME

    sample - Using GetOpt::Long and Pod::Usage

=head1 SYNOPSIS

    sample [options] [file ...]
     Options:
       -help            brief help message
       -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do someting
useful with the contents thereof.

=cut
