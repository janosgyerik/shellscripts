#!/usr/bin/env perl
#
# SCRIPT: atime.pl
# AUTHOR: janos <janos@axiom>
# DATE:   2014-03-04
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
# PLATFORM: Linux only
# PLATFORM: FreeBSD only
#
# PURPOSE: Print access time of specified files.
#

use strict;
use warnings;

my @args;
#my  = '';
#my  = '';
#my  = '';
my $format = '';

OUTER: while (@ARGV) {
    for (shift(@ARGV)) {
        ($_ eq '-h' || $_ eq '--help') && do { &usage(); };
        # ($_ eq '-f' || $_ eq '--flag') && do { $flag = 1; last; };
        # ($_ eq '-p' || $_ eq '--param') && do { $param = shift(@ARGV); last; };
        ($_ eq '-f' || $_ eq '--format') && do { $format = shift(@ARGV); last; };
        ($_ eq '--') && do { push(@args, @ARGV); undef @ARGV; last; };
        ($_ =~ m/^-.+/) && do { &usage("Unknown option: $_"); };
        push(@args, $_);  # script that takes multiple arguments
        # $arg ? $arg = $_ : &usage();  # strict with excess arguments
        # $arg = $_;  # forgiving with excess arguments
    }
}

sub bool2string() {
    return $_[0] ? "true" : "false";
}

sub usage() {
    print @_, "\n" if @_;
    $0 =~ m/[^\/]+$/;
    print "Usage: $& [OPTION]... [ARG]...\n\n";
    print "Print access time of specified files\n";
    print "\nOptions:\n";
    print "  -f, --format FORMAT  default = $format\n";
    print "\n";
    print "  -h, --help           Print this help\n";
    print "\n";
    exit(1);
}

&usage() unless @args;

foreach my $fn (@args) {
    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
        $atime,$mtime,$ctime,$blksize,$blocks) = stat($fn);
    print $fn, "\t", scalar localtime $atime, "\n";
}
