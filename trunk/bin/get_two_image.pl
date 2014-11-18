#!/usr/bin/perl -w
use strict;

use DBI;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use Net::SSH::Expect;
use Net::SCP::Expect;
use JSON::Parse qw(parse_json valid_json);

our $SCP = '';
our $SSH = '';
our $DBH = '';
our $ISERVER = '10.155.30.230';
our $IUSER = 'root';
our $IPWD = 'aerohive';
our $ISRC_DIR = '/tftpboot/newimg';
our $IDST_DIR = '/tftpboot';

my $man = 0;
my $help = 0;
my $debug = 0;
my $jsona = '';
my $jsonb = '';

my $obja = '';
my $objb = '';
my $image_a = '';
my $image_b = '';

GetOptions(
    'help|?'     => \$help,
    man          => \$man,
    'debug|d'    => \$debug,
    'imagea|a=s' => \$jsona,
    'imageb|b=s' => \$jsonb,
    
) or pod2usgae(2);

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

sub connect_db{
    my $db_host = '10.155.40.241';
    my $db_name = 'awp';
    my $db_user = 'awper';
    my $db_passwd = 'aerohive';
    my $dsn = "DBI:mysql:database=$db_name;host=$db_host;mysql_read_default_group_=client";
    $DBH = DBI->connect(
        $dsn, $db_user, $db_passwd,
        {'RaiseError' => 1}
    ) unless $DBH;
    if(!$DBH){
        die "Cannot connect to $dsn: $!";
    }
}

sub get_branch_keyword{
    my $b = shift;
    connect_db();
    
    my $sth = $DBH->prepare("SELECT Keyword FROM AWP_ImageKeyword WHERE Branch='$b'");
    $sth->execute;
    my $kw = '';
    while(my @arr = $sth->fetchrow_array()){
        $kw = $arr[0];
    }
    $kw =~ s/,/|/g;
    return "($kw)";
}

sub validate_param{
    die "Cannot get object info, need two object instances\n" unless ($jsona && $jsonb);

    if (valid_json($jsona)) {
        $obja = parse_json($jsona);
        print ">>>> Get image a object: \n", Dumper($obja), "\n" if $debug;
    }
    else {
        die ">>>> JSON Object a is invalid: $@\n";
    }
    
    if (valid_json($jsonb)) {
        $objb = parse_json($jsonb);
        print ">>>> Get image b object: \n", Dumper($objb), "\n" if $debug;
    }
    else {
        die ">>>> JSON Object b is invalid: $@\n";
    }
    
    die "No dut type for object a\n" unless $obja->{type};
    die "No dut type for object b\n" unless $objb->{type};
}

sub download_img_to_mpc{
    my $img = shift;
    my $local_img = `ls $IDST_DIR |grep $img`;
    
    if ($local_img) {
        print "local image: $img\n" if $debug;
        return 0;
    }
    
    $SCP = Net::SCP::Expect->new(
        user     => $IUSER,
        password => $IPWD,
        auto_yes => 1,
    ) unless $SCP;
    
    $SCP->scp("$ISERVER:$ISRC_DIR/$img", "$IDST_DIR") or die "Cannot download image, $!";
    $local_img = `ls $IDST_DIR |grep $img`;
    
    if ($local_img) {
        print "download image success: $img\n" if $debug;
        return 0;
    }
    else{
        die "Cannot find image in $IDST_DIR\n";
    }
}

sub grep_img{
    my @kws = @_;
    my $cmd = join " | ", map { "grep -P \"$_\"" } @kws;
    $cmd = "ls -rt1 $ISRC_DIR | $cmd";
    
    if (!$SSH) {
        $SSH = Net::SSH::Expect->new(
            host => $ISERVER,
            user => $IUSER,
            password => $IPWD,
            raw_pty => 1,
            timeout => 3,
        );
        $SSH->login();
    }
    print "CMD: $cmd\n" if $debug;
    $SSH->exec("stty raw -echo");
    my $rc = $SSH->exec($cmd);
    my @imgs = split /\n/, $rc;
    pop @imgs;
    return \@imgs;
}

sub is_use_similar_img{
    if ($obja->{'type'} eq $objb->{'type'}) {
        if ($objb->{'keyword'} ne ''){
            if ($objb->{'keyword'} eq $obja->{'keyword'}) {
                return 1
            }
            else{
                return 0;
            }
        }
        elsif($objb->{'keyword'} eq ''){
            if ($obja->{'branch'} eq $objb->{'branch'}) {
                return 1;
            }
            else{
                return 0;
            }
        }
        else{
            return 0;
        }
    }
    else{
        return 0;
    }
}


sub main{}
validate_param();
my @imga_list = ();
my @imgb_list = ();
my $keyword_a = $obja->{'keyword'} ? $obja->{'keyword'} :
                get_branch_keyword($obja->{'branch'});
if ($keyword_a =~ m/\.img(.S)?$/i) {
    if (!download_img_to_mpc($keyword_a)) {
        $image_a = $keyword_a;
        print "image_a.name=$image_a\n";
    }
}
else{
    @imga_list = @{grep_img($obja->{'type'}, $keyword_a)};
    print "image a list: \n", Dumper(\@imga_list) if $debug;
    if (@imga_list) {
        $image_a = $imga_list[$#imga_list];
        print "image_a.name=$image_a\n" if (!download_img_to_mpc($image_a));
    }
    else{
        print "Cannot get image a\n";
        exit 1;
    }
}

my $keyword_b = $objb->{'keyword'} ? $objb->{'keyword'} :
                get_branch_keyword($objb->{'branch'});
if ($keyword_b =~ m/\.img(.S)?$/i) {
    if (!download_img_to_mpc($keyword_b)) {
        $image_b = $keyword_b;
        print "image_b.name=$image_b\n";
    }
}
elsif($objb->{'type'} eq $obja->{'type'} && $keyword_b eq $keyword_a){
    pop @imga_list;
    if (@imga_list) {
        $image_b = $imga_list[$#imga_list];
        print "image_b.name=$image_b\n" if (!download_img_to_mpc($image_b));
    }
    else{
        print "Cannot get image b\n";
        exit 3;
    }
}
else{
    @imgb_list = @{grep_img($objb->{'type'}, $keyword_b)};
    print "image b list: \n", Dumper(\@imgb_list) if $debug;
    if ($imgb_list[$#imgb_list] eq $image_a) {
        pop @imgb_list;
    }
    if (@imgb_list) {
        $image_b = $imgb_list[$#imgb_list];
        print "image_b.name=$image_b\n" if (!download_img_to_mpc($image_b));
    }
    else{
        print "Cannot get image b\n";
        exit 2;
    }
}

$DBH->disconnect if $DBH;

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
