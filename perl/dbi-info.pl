#!/usr/bin/perl
#
# SCRIPT: dbi-info.pl
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-01-27
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Print the list of available DBI drivers and data sources.
#

use strict;
use warnings;

#&usage() unless @ARGV;

my @args;

my $all = "";
OUTER: while (@ARGV) {
    for (shift(@ARGV)) {
        ($_ eq '-h' || $_ eq '--help') && do { &usage(); };
        ($_ eq '-a' || $_ eq '--all') && do { $all = 1; last; };
        ($_ eq '--') && do { push(@args, @ARGV); undef @ARGV; last; };
        ($_ =~ m/^-.+/) && do { print "Unknown option: $_\n"; &usage(); };
        push(@args, $_);
    }
}

sub usage {
    $0 =~ m|[^/]+$|;
    print "Usage: $& [-h|--help] [-a|--all]\n";
    print "\n";
    print "Print the list of available DBI drivers and data sources\n";
    exit 1;
}

use DBI;

print qq{Available drivers: }.join(", ", &DBI::available_drivers()).qq{\n};

@args = &DBI::available_drivers() if $all;

foreach my $driver (@args) {
    print "Data sources of driver '$driver':\n";
    my @sources;
    eval { @sources = DBI->data_sources($driver) };
    print map("  $_\n", grep($_, @sources));
}
