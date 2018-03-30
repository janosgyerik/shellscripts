#!/usr/bin/perl
#
# SCRIPT: geoip-lookup.pl
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-02-10
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Find the country of a hostname or IP address using Geo::IPfree
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
    print "Usage: $& [-h|--help] host1 ...\n";
    print "\n";
    print "Find the country of a hostname or IP address using Geo::IPfree\n";
    exit;
}

require Geo::IPfree;
my $GeoIP = Geo::IPfree::new();

foreach my $host (@args) {
    print join("\t", $GeoIP->LookUp($host)), "\n";
}
