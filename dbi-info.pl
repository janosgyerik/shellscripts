#!/usr/local/bin/perl
#
# SCRIPT: dbi-info.pl
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2005-01-27
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Obtain info about available DBI drivers and data sources.
#
# REV LIST:
#        DATE:	DATE_of_REVISION
#        BY:	AUTHOR_of_MODIFICATION   
#        MODIFICATION: Describe what was modified, new features, etc-
#
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
    print qq{usage: $& [-h|--help] [-a|--all]\n};
    exit;
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

# eof
