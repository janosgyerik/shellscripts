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

exit usage(1) unless @ARGV;

my @args;
my $encode = 1;

while (@ARGV) {
    local $_ = shift @ARGV;
    if ($_ eq '-h' || $_ eq '--help') {
        exit usage(0);
    } elsif ($_ eq '-D' || $_ eq '--decode') {
        $encode = 0;
    } elsif ($_ eq '--') {
        push(@args, @ARGV);
        undef @ARGV;
    } elsif ($_ =~ m/^-/) {
        print "Unknown option: $_\n";
        exit usage(1);
    } else {
        push(@args, $_);
    }
}

sub usage {
    my ($status) = @_;
    my $old_fh = select STDERR if $status;

    $0 =~ m|[^/]+$|;
    print "Usage: $& [-h|--help] [-D|--decode]\n";
    print "\n";
    print "Encode (= default) or decode Base64\n";

    select $old_fh if $old_fh;
    return $status;
}

use MIME::Base64 qw/encode_base64 decode_base64/;
my $converter = $encode ? \&encode_base64 : \&decode_base64;
print map($converter->($_), @args);
