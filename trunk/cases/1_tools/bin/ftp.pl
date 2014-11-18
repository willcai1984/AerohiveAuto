#!/usr/bin/perl

use strict;
use warnings;
use Net::FTP;
use File::Basename;

my $ftp_server = shift;
my $action = shift;
my $filepath = shift;

die "need specify ftp server!\n" unless $ftp_server;
die "need specify action(get|put)!\n" unless $action;
die "need specify file!\n" unless $filepath;
die "need full path for file!\n" unless($filepath =~ m(^/));

my $file = basename($filepath);
my $dir = dirname($filepath);

my $ftp = Net::FTP->new($ftp_server, Debug => 0)
    or die "Cannot connect to $ftp_server: $@";
$ftp->login("logger", "aerohive")
    or die "Cannot login ", $ftp->message;
$ftp->cwd($dir)
    or die "Cannot change working directory ", $ftp->message;
$ftp->binary
    or die "Cannot use binary mode ", $ftp->message;

if($action eq 'get'){
    $ftp->get($file)
        or die "get file failed ", $ftp->message;
}
$ftp->quit;