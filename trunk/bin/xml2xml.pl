#!/usr/bin/perl -w

use strict;
use Switch;
use Template;
use File::Spec;
use File::Basename;
#use diagnostics;
use XML::Simple;
use Data::Dumper;
use Getopt::Long qw(GetOptionsFromString);

my %rule = (
    '$G_SERVIP_NTP0' => '${pub.ntp}',
    '$G_TESTBED' => '${tb.name}',
    '${G_TESTBED}' => '${tb.name}',
    '$G_TESTBED-hive' => '${hive.name}',
    '$U_TESTCONF' => '${case.dir}/conf',
    '$U_TESTPATH' => '${case.dir}',
    '$G_TESTBED-$G_PROD_DESC0' => '${ssid.name}',
    '$G_SERVIP_RADIUSD0' => '${pub.radius1.ip}',
    '$G_SVR_RADSECRET0' => '${pub.radius1.sharesecret}',
    '$G_SVR_RADUSER0' => '${pub.radius1.username}',
    '${G_SVR_RADUSER0}' => '${pub.radius1.username}',
    '$G_SVR_RADPWD0' => '${pub.radius1.passwd}',
    '$G_TB_DRVIER' => '${sta1.wpa_flag}',
    '$G_CURRENTLOG' => '${log.dir}',
    '${G_HOST_TIP1_0_0%/*}' => '${sta1.mif.ip}',
    '$G_HOST_TIP1_0_0' => '${sta1.mif.ip}',
    '${G_HOST_TIP2_0_0%/*}' => '${sta2.mif.ip}',
    '$G_HOST_TIP2_0_0' => '${sta2.mif.ip}',
    '${G_HOST_TIP0_1_0%/*}' => '${mpc.tif.ip}',
    '$G_HOST_TIP0_1_0' => '${mpc.tif.ip}',
    '$G_HOST_TIP1_1_0' => '${sta1.tif.ip}',
    '${G_HOST_TIP1_1_0%/*}' => '${sta1.tif.ip}',
    '$G_HOST_TIP2_1_0' => '${sta2.tif.ip}',
    '${G_HOST_TIP2_1_0%/*}' => '${sta2.tif.ip}',
    '$G_HOST_IF1_1_0' => '${sta1.tif.name}',
    '$G_HOST_IF2_1_0' => '${sta2.tif.name}',
    '${LAPTOP_IP%/*}' => '${sta1.tif.ip}',
    '${LAPTOP1_IP%/*}' => '${sta1.tif.ip}',
    '${LAPTOP2_IP%/*}' => '${sta2.tif.ip}',
    '$LAPTOP_MAC' => '${sta1.tif.mac}',
    '$LAPTOP1_MAC' => '${sta1.tif.mac}',
    '$LAPTOP2_MAC' => '${sta2.tif.mac}',
    '$G_HOST_USR0' => '${pc.def.user}',
    '$G_HOST_PWD0' => '${pc.def.password}',
    '$G_TS_USR0' => '',
    '$G_TS_PWD0' => '',
    '$G_HOST_USR1' => '${sta1.user}',
    '$G_HOST_PWD1' => '${sta1.passwd}',
    '$G_HOST_USR2' => '${sta2.user}',
    '$G_HOST_PWD2' => '${sta2.passwd}',
    '$G_TS_CONSNAME0_0_0' => '${ap1.cons_name}',
    '$G_TS_CONSNAME0_1_0' => '${ap2.cons_name}',
    '$U_COMMONBIN' => '${bin.dir}',
    '$AP1_IP_ETH0' => '${ap1.mgt0.ip}',
    '${AP1_IP_ETH0%/*}' => '${ap1.mgt0.ip}',
    '$AP2_IP_ETH0' => '${ap2.mgt0.ip}',
    '${AP2_IP_ETH0%/*}' => '${ap2.mgt0.ip}',
    '$G_PROD_IP_ETH0_0_0' => '${ap1.mgt0.ip}',
    '${G_PROD_IP_ETH0_0_0%/*}' => '${ap1.mgt0.ip}',
    '$G_PROD_GW_ETH0_0_0' => '${ap1.mgt0.gw}',
    '$G_PROD_IP_ETH0_1_0' => '${ap2.mgt0.ip}',
    '$G_PROD_GW_ETH0_1_0' => '${ap2.mgt0.gw}',
    '$G_PROD_RADIUSD1_ETH0_0_0' => '${pub.radius1.ip}',
    '${G_PROD_RADIUSD1_ETH0_0_0%/*}' => '${pub.radius1.ip}',
    '$G_PROD_RADIUSD1_ETH0_1_0' => '${pub.radius1.ip}',
    '${G_PROD_RADIUSD1_ETH0_1_0%/*}' => '${pub.radius1.ip}',
    '$G_SERVIP_MANIP0' => '${pub.tftp1.ip}',
    '$G_SWITCH_VLAN_NATIVE_PORT0_0_0' => '${tb.nvlan}',
    '$G_SWITCH_VLAN_NATIVE_PORT0_1_0' => '${tb.nvlan}',
    '$G_SWITCH_VLAN_NATIVE_PORT0_2_0' => '${tb.nvlan}',
    '$G_SWITCH_VLAN_NATIVE_PORT0_3_0' => '${tb.nvlan}',
    '$G_SWITCH_VLAN_CFG_PORT0_1_0' => '${tb.vlan1}',
    '$G_SWITCH_VLAN_CFG_PORT0_1_1' => '${tb.vlan2}',
    '$G_SWITCH_VLAN_CFG_PORT0_1_2' => '${tb.vlan3}',
    '$G_SWITCH_VLAN_CFG_PORT0_2_0' => '${tb.vlan1}',
    '$G_SWITCH_VLAN_CFG_PORT0_2_1' => '${tb.vlan2}',
    '$G_SWITCH_VLAN_CFG_PORT0_2_2' => '${tb.vlan3}',
    '$G_SWITCH_VLAN_CFG_PORT0_3_0' => '${tb.vlan1}',
    '$G_SWITCH_VLAN_CFG_PORT0_3_1' => '${tb.vlan2}',
    '$G_SWITCH_VLAN_CFG_PORT0_3_2' => '${tb.vlan3}',
    '${G_SWITCH_VLAN_CFG_PORT0_3_1}' => '${tb.vlan2}',
    '$G_HOST_IP0' => '${mpc.mif.ip}',
    '$G_HOST_IP1' => '${sta1.mif.ip}',
    '$G_HOST_IP2' => '${sta2.mif.ip}',
    '$DUT1_WIFI01_MAC' => '${ap1.wifi0_1.mac}',
    '$DUT1_WIFI02_MAC' => '${ap1.wifi0_2.mac}',
    '$DUT1_WIFI11_MAC' => '${ap1.wifi1_1.mac}',
    '$DUT1_WIFI12_MAC' => '${ap1.wifi1_2.mac}',
    '$G_USER_MS_IP' => '${mpc.tif.ip}',
    '$G_USER_AP1_IP' => '${ap1.mgt0.ip}',
    '$G_USER_AP1_MAC' => '${ap1.mgt0.mac}',
    '$G_USER_AP1_GW' => '${ap1.mgt0.gw}',
    '$G_USER_AP2_IP' => '${ap1.mgt0.ip}',
    '$G_USER_AP2_MAC' => '${ap1.mgt0.mac}',
    '$G_USER_AP2_GW' => '${ap1.mgt0.gw}',
    '$G_USER_AP3_IP' => '${ap1.mgt0.ip}',
    '$G_USER_AP3_MAC' => '${ap1.mgt0.mac}',
    '$G_USER_AP3_GW' => '${ap1.mgt0.gw}',
    '$G_USER_PC1_IP' => '${sta1.tif.ip}',
    '$G_USER_PC1_gw' => '${sta1.tif.gw}',
    '$G_USER_PC1_mac' => '${sta1.tif.mac}',
    '$G_USER_PC2_IP' => '${sta2.tif.ip}',
    '$G_USER_PC2_gw' => '${sta2.tif.gw}',
    '$G_USER_PC2_mac' => '${sta2.tif.mac}',
    'G_USER_MASTER_IP' => '${mpc.tif.ip}',
    '${ssid.name}' => '${ssid.name}',
    );

my %setVarRule = ();
sub replaceENV{
    my $string = shift @_;
    
    $string =~ s/\$G_TESTBED-\${G_PROD_DESC0}/\${ssid.name}/g;
    my @str = split //, $string;
    my @repStr = ();
    my $current = 0;
    my $bakPos = 0;
    my $pattern = '';
    for(; $current <= $#str; $current++){
        my $curChar = $str[$current];
        if($curChar ne '$'){
            push @repStr, $curChar;
            next;
        }
        else{
            $pattern .= $curChar;
            $bakPos = $current;
            my $nextChar = $str[++$current];
            if($nextChar eq '{'){
                $pattern .= $nextChar;
                $current++;
                while($str[$current] ne '}'){
                    $pattern .= $str[$current++];
                }
                $pattern .= $str[$current];
                if(defined($rule{$pattern})){
                    push @repStr, $rule{$pattern};
                    #$pattern = '';
                    #next;
                }
                elsif(defined($setVarRule{$pattern})){
                    push @repStr, $setVarRule{$pattern};
                }
                else{
                    #die "Pattern: $pattern is not defined!\n";
                    print "Pattern: $pattern is not defined!\n";
                    push @repStr, $pattern;
                }
                $pattern = '';
                next;
            }
            else{
                $pattern .= $nextChar;
                $current++;
                while(defined($str[$current]) && $str[$current] =~ m/[\w\-\$]/){
                    $pattern .= $str[$current++];
                }
                if($pattern eq '$SQAROOT'){
                    push @repStr, '${bin.dir}';
                    #$pattern = '';
                    $current += 7;
                    #next;
                }
                elsif(defined($rule{$pattern})){
                    push @repStr, $rule{$pattern};
                    push @repStr, $str[$current] if defined $str[$current];
                    #$pattern = '';
                    #next;
                }
                elsif(defined($setVarRule{$pattern})){
                    push @repStr, $setVarRule{$pattern};
                    push @repStr, $str[$current] if defined $str[$current];
                    #$pattern = '';
                    #next;
                }
                else{
                    #die "Pattern: $pattern is not defined!\n";
                    print "Pattern: $pattern is not defined!\n";
                    push @repStr, $pattern;
                    push @repStr, $str[$current] if defined $str[$current];
                }
                $pattern = '';
                next;
            }
            
        }
    }
    my $ret = join '', @repStr;
    $ret =~ s/AP(\d)_IP_ETH0/\${ap$1.mgt0.ip}/g;
    $ret =~ s/LAPTOP1?_MAC/\${sta1.tif.mac}/g;
    $ret =~ s/LAPTOP1?_IP/\${sta1.tif.ip}/g;
    $ret =~ s/LAPTOP2_MAC/\${sta2.tif.mac}/g;
    $ret =~ s/LAPTOP2_IP/\${sta2.tif.ip}/g;
    
    return $ret;
}

sub replaceENV_old{
    my $string = shift @_;

    while(m/(\${[^}]*})/g){
        die "Find new pattern: $1, need to be added to rule\n"
          unless defined $rule{$1};
    }
    while(m/(\$[\w\-\$]+)/g){
        die "Find new pattern: $1, need to be added to rule\n"
          unless defined $rule{$1};
    }
    $string =~ s/(\${[^}]*})/$rule{$1}/g;
    $string =~ s/(\$[\w\-\$]+)/$rule{$1}/g;

    return $string;
}

my $caseFile = shift @ARGV;
if(!defined $caseFile){
    my $usage = <<USAGE;
Usage: xml2xml.pl file
Exp: xml2xml.pl E:\\auto_case\\cases\\AccessConsole\\ft_accessconsole_3.xml
USAGE
    
    print $usage;
    exit 1;
}

my $replaceUserVar = shift @ARGV;
$caseFile = File::Spec->rel2abs($caseFile);
my $dir = dirname($caseFile);
my $basename = basename($caseFile);
chdir $dir;

print "$dir\n$basename\n";
#my $caseDir = 'E:\auto_case\cases\NormalAuthType';
#my $caseFile = 'ft_auth_eap_peap_1_1.xml';
#chdir $caseDir;

#hash referrence to store read-in XML structure
my $xmlIn = XMLin($caseFile);
#hash referrence to store output XML structure
my @steps = ();
my @final = ();
my $xmlOut = {
    brief => '',
    priority => '',
    automated => 'no',
    description => '',
    steps => \@steps,
    failedprocess => \@final,
};
$xmlOut->{brief} = ($xmlIn->{emaildesc} ne '') ? $xmlIn->{emaildesc} : $xmlIn->{name};
$xmlOut->{priority} = $xmlIn->{priority};
$xmlOut->{description} = $xmlIn->{description};
my %xmlSteps = %{$xmlIn->{stage}->{step}};
#print Dumper(\%xmlSteps);

my %ss = ();
my $failedStartStep = 1000;
my $no = 1;
my $fno = 1;
my $delay = 0;
my $sdesc = '';
my $log = '';
my $timeout = 0;
my $console = '';
my $telnet = '';
my $ssh = '';
my $varname = '';
my $getvar = '';
my $script = '';
my @match = ();
my $noerrorcheck = 0;
my $passed = '';
my $failed = '';

my %logMatch_step = ();
sub pushStep{
    my $currentNum = shift @_;
    my %step = ();

    $step{desc} = $sdesc;
    if($delay != 0){
        $step{delay} = $delay;
        $delay = 0;
    }
    if($log ne ''){
        $step{log} = $log;
        if(defined $logMatch_step{$log}){
            push @{$logMatch_step{$log}}, $no;
        }
        else{
            $logMatch_step{$log} = [];
            push @{$logMatch_step{$log}}, $no;
        }
        $log = '';
    }
    if($timeout != 0){
        $step{timeout} = $timeout;
        $timeout = 0;
    }
    if($console ne ''){
        $step{console} = $console;
        $console = '';
    }
    if($telnet ne ''){
        $step{telnet} = $telnet;
        $telnet = '';
    }
    if($ssh ne ''){
        $step{ssh} = $ssh;
        $ssh = '';
    }
    if($varname ne ''){
        $step{varname} = $varname;
        $varname = '';
    }
    if($getvar ne ''){
        $step{getvar} = $getvar;
        $getvar = '';
    }
    if($script ne ''){
        $step{script} = $script;
        $script = '';
    }
    if($#match != -1){
        my @match_tmp = @match;
        $step{logmatch} = \@match_tmp;
        @match = ();
    }
    if($noerrorcheck != 0){
        $step{noerrorcheck} = $noerrorcheck;
        $noerrorcheck = 0;
    }
    if($passed ne ''){
        $step{passed} = $passed;
        $passed = '';
    }
    if($failed ne ''){
        $step{failed} = $failed;
        $failed = '';
    }
        
    if($currentNum >= $failedStartStep){
        $step{no} = $fno;
        push @final, \%step;
        $fno++;
    }else{
        $step{no} = $no;
        push @steps, \%step;
        $no++;
    }
    #print Dumper(\@steps);
}

sub getOpt{
    my ($script, @opt) = @_;
    Getopt::Long::Configure("pass_through");
    my $ret = '';
    my @args = ();
    my ($success, $args) =
    GetOptionsFromString($script,
                         "v=s" => sub { push @args, "-v \"$_[1]\"" },
                         "f=s" => sub { push @args, "-f ". basename($_[1]) },
                        );
    $ret = join "\n", @args;
    return $ret;
}

foreach my $num (sort {$a <=> $b} keys %xmlSteps){
    #print "$num\n";
    %ss = %{$xmlSteps{$num}};
    
    $sdesc = $ss{desc};
    if($ss{failed} =~ m/^\d+$/){
        $failedStartStep = ($ss{failed} < $failedStartStep) ? $ss{failed} : $failedStartStep;
    }
    $noerrorcheck = 1 if(defined $ss{noerrorcheck} && $ss{noerrorcheck} == 1);
    $noerrorcheck = 1 if(defined $ss{nonerrorcheck} && $ss{nonerrorcheck} == 1);
    $passed = $ss{passed} if ref($ss{passed}) ne 'HASH';
    
    if(defined($ss{script}) && (ref($ss{script}) ne 'HASH')){
        #if script end with exit 0, we should check it manually
        $ss{script} =~ s/;\s*exit\s+0/:exit 0/i;
        #$ss{script} =~ s/(\n|\\)"?//g;
        $ss{script} =~ s/(\n|\\(?=\s*\n))//g;
        #my @cmd = grep {!/^\s*$/} split /;/, $ss{script};
        my @cmd = split /;/, $ss{script};
        foreach (@cmd){
            switch($_){
                case m/sleep\s+\d+/i {
                    m/sleep\s+(\d+)/i;
                    $delay = $1;
                }
                case m/clicfg\.pl/i {
                    m/clicfg\.pl.*?-i\s+(\d+)\s+/i;
                    my $port = $1;
                    $timeout = $1 if m/-o\s+(\d+)/i;
                    #$log = $1 if m/-t\s+([\w-]+\.log)/;
                    $log = $1 if m/-t\s+(.*?\.log)/;
                    my $params = '';
                    #$params .= "$1\n" while m/(-[vf]\s+"?[^"]*"?)\s+/g;
                    $params = getOpt($_, 'f', 'v');
                    switch($port){
                        case 782 {
                            $console = $params;
                            pushStep($num);
                        }
                        case 23  {
                            $telnet = $params;
                            pushStep($num);
                        }
                        case 22  {
                            $ssh = $params;
                            pushStep($num);
                        }
                    }
                }
                case m/searchoperation\.pl/i {
                    $log = $1 if m/-f\s+.*?\/(.*?\.log)/;
                    push @match, replaceENV($');
                    #print Dumper(\@match);
                    pushStep($num);
                }
                else {
                    $script = $_;
                    pushStep($num);
                }
            }
        }
    }
    elsif(defined($ss{getenv}) && (ref($ss{getenv}) ne 'HASH')){
        #$ss{getenv} =~ s/(\n|\\)"?//g;
        if(defined $replaceUserVar && $replaceUserVar eq 'ruv'){
            my $parsevar = $1 if $ss{getenv} =~ m/echo\s+(\w+)=/i;
            $varname = lc $parsevar;
            warn "Duplicate setvar name: $parsevar\n" if(defined $setVarRule{"\$$parsevar"});
            $setVarRule{"\$$parsevar"} = $varname;
            $setVarRule{"$varname"} = $varname;
        }
        else{
            $varname = $1 if $ss{getenv} =~ m/echo\s+(\w+)=/i;
        }
        $getvar = $1 if $ss{getenv} =~ m/=\$\((.*)\)/;
        pushStep($num);
    }
    elsif(ref($ss{script}) eq 'HASH' || ref($ss{getenv}) eq 'HASH'){
        print "No script specified at step $num, check for that!\n";
        next;
    }
    else{
        die "Cannot handle step:\n", Dumper(\%ss);
    }  
}

#print Dumper(\%logMatch_step);
#print Dumper(\@steps);
foreach my $logName (keys %logMatch_step){
    my @stepLog = @{$logMatch_step{$logName}};
    next if $#stepLog == 0;
    my $firstLogStep = shift @stepLog;
    
    foreach (@stepLog){
        next unless defined $steps[$_ - 1]->{logmatch};
        if(defined($steps[$firstLogStep - 1]->{logmatch})){
            push @{$steps[$firstLogStep - 1]->{logmatch}}, @{$steps[$_ - 1]->{logmatch}};
        }
        else{
            $steps[$firstLogStep - 1]->{logmatch} = [];
             push @{$steps[$firstLogStep - 1]->{logmatch}}, @{$steps[$_ - 1]->{logmatch}};
        }
        delete $steps[$_ - 1];
    }
}
my $index = 1;
@steps = map {$_->{no} = $index; $index++; $_} grep {defined($_)} @steps;

################ replace Environment ################
#print Dumper(\@steps);

foreach (@steps, @final){
    #my %hStep = %{$_};
    foreach my $key (keys %{$_}){
        next unless ref($_->{$key}) ne 'ARRAY';
        $_->{$key} =~ s/^\s*//;
        $_->{$key} =~ s/\s*$//;
        $_->{$key} = replaceENV($_->{$key});
    }
}
#print Dumper(\@steps);

############### generate XML file #####################
my $templateDir = dirname($0);
my $tt = Template->new({
        INCLUDE_PATH => $templateDir,
        INTERPOLATE  => 1,
}) || die "$Template::ERROR\n";

my $templateFile = 'tesecase.xml';
rename $basename, "old_$basename";
$tt->process($templateFile, $xmlOut, "$basename");

print "Done!\n";