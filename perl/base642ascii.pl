#!/usr/bin/perl
#
# SCRIPT: base642ascii.pl
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-07-14
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Convert a Base64 string to ASCII
#

use strict;
use warnings;

&usage() unless @ARGV;

my @args;

OUTER: while (@ARGV) {
    for (shift(@ARGV)) {
        ($_ eq '-h' || $_ eq '--help') && do { &usage(); };
        ($_ eq '--') && do { push(@args, @ARGV); undef @ARGV; last; };
        ($_ =~ m/^-.+/) && do { print "Unknown option: $_\n"; &usage(); };
        push(@args, $_);
    }
}

sub usage {
    $0 =~ m|[^/]+$|;
    print "Usage: $& [-h|--help]\n";
    print "\n";
    print "Convert a Base64 string to ASCII\n";
    exit 1;
}

use MIME::Base64;
print &MIME::Base64::decode_base64(@args), "\n";

# eof
