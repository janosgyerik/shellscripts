#!/usr/bin/env perl

&usage() if $#ARGV < 1 || $ARGV[0] eq '-h' || $ARGV[0] eq '--help';

sub usage {
    print "Usage: pie.pl [-h|--help] EXPR FILE...\n\n";
    print "Apply expression on the content of files, for example s/foo/bar/g\n";
    exit 1;
}

my $eval = shift @ARGV;
foreach my $file (@ARGV) {
    next unless -f $file;
    open my $fd, $file;
    my $content = do { local $/; <$fd>; };
    close $fd;
    my $new = do { $_ = $content; eval $eval; };
    if ($content ne $new) {
        open my $fd, ">", $file;
        print $fd $_;
        close $fd;
    }
}
