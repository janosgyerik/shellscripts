#!/usr/bin/env perl
#
# SCRIPT: base64.pl
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-07-14
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Encode (= default) or decode Base64
#

use strict;
use warnings;

&usage() unless @ARGV;

my @args;
my $encode = 1;

while (@ARGV) {
    local $_ = shift @ARGV;
    ($_ eq '-h' || $_ eq '--help') && do { &usage(); };
    ($_ eq '-D' || $_ eq '--decode') && do { $encode = ! $encode; next; };
    ($_ eq '--') && do { push(@args, @ARGV); undef @ARGV; next; };
    ($_ =~ m/^-.+/) && do { print "Unknown option: $_\n"; &usage(); };
    push(@args, $_);
}

sub usage {
    $0 =~ m|[^/]+$|;
    print "Usage: $& [-h|--help] [-D|--decode]\n";
    print "\n";
    print "Encode (= default) or decode Base64\n";
    exit 1;
}

use MIME::Base64 qw/encode_base64 decode_base64/;
my $converter = $encode ? \&encode_base64 : \&decode_base64;
print map($converter->($_), @args);
