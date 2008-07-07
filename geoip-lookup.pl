#!/usr/local/bin/perl
#
# SCRIPT: geoip-lookup.pl
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2005-02-10
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Simply a command line interface for the Geo::IPfree perl package
#          to look up country of IP addresses or hostnames specified on the
#          command line. Requires the Geo::IPfree perl module.
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

while (@ARGV) {
    for (shift(@ARGV)) {
        ($_ eq '-h' || $_ eq '--help') && do { &usage(); };
        ($_ eq '--') && do { push(@args, @ARGV); undef @ARGV; last; };
        ($_ =~ m/^-.+/) && do { print "Unknown option: $_\n"; &usage(); };
        push(@args, $_);
    }
}

sub usage {
    $0 =~ m|[^/]+$|;
    print qq{usage: $& [-h|--help] host1 ...\n};
    exit;
}

use Geo::IPfree;
my $GeoIP = Geo::IPfree::new();

foreach my $host (@args) {
    print join("\t", $GeoIP->LookUp($host)), "\n";
}

# eof
