#!/usr/local/bin/perl
#
# SCRIPT: base642ascii.pl
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2005-07-14
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
# PLATFORM: Linux only
# PLATFORM: FreeBSD only
#
# PURPOSE: Give a clear, and if necessary, long, description of the
#          purpose of the shell script. This will also help you stay
#          focused on the task at hand.
#
# REV LIST:
#        DATE:	DATE_of_REVISION
#        BY:	AUTHOR_of_MODIFICATION   
#        MODIFICATION: Describe what was modified, new features, etc-
#
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
    print qq{usage: $& [-h|--help]\n};
    exit;
}

use MIME::Base64;
print &MIME::Base64::decode_base64(@args), "\n";

# eof
