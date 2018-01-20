#!/usr/bin/perl
#
# SCRIPT: FreeBSD.pl
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2004-11-25
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: FreeBSD (confirmed on 5.3)
#
# PURPOSE: A package manager for FreeBSD emulating some of the functionality
#          of apt-get and apt-cache in Debian based systems, in particular:
#          search, download, install, remove
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

use strict;

-f $ENV{HOME}.'/.FreeBSD.pl' && do $ENV{HOME}.'/.FreeBSD.pl';

my $INDEX = $CFG::INDEX || $ENV{HOME}.'/local/FreeBSD.pl/INDEX';
my $FILES = $CFG::FILES || $ENV{HOME}.'/local/FreeBSD.pl/packages';

&usage() unless @ARGV;

my @args;
my $match = "BOTH";
my $action = "";
my $verbosity = 0;
my @targets;
my @targets_fix;

OUTER: while (@ARGV) {
    for (shift(@ARGV)) {
        ($_ eq '-h' || $_ eq '--help') && do { &usage; };
        ($_ eq '--index') && do { &fetch_index(); last; };
        ($_ eq '-i' || $_ eq '--install') && do { $action = "INSTALL"; last; };
        ($_ eq '-r' || $_ eq '--remove') && do { $action = "REMOVE"; last; };
        ($_ eq '-f' || $_ eq '--fetch') && do { $action = "FETCH"; last; };
        ($_ eq '-n' || $_ eq '--name') && do { $match = "NAME"; last; };
        ($_ eq '-d' || $_ eq '--description') && do { $match = "DESCRIPTION"; last; };
        ($_ eq '-s' || $_ eq '--silent') && do { $verbosity = - $verbosity - 1; last; };
        ($_ eq '-v' || $_ eq '--verbose') && do { ++$verbosity; last; };
        push(@args, $_);
    }
}

die 'Set $ENV{URL_FREEBSD} to the base URL of package files,
so that $ENV{URL_FREEBSD}/INDEX and $ENV{URL_FREEBSD}/All make sense.
For example:
export URL_FREEBSD=ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/9.2-RELEASE/packages
' unless exists($ENV{URL_FREEBSD});

system(qq{test ! -d "$FILES" && mkdir -p "$FILES"});
if (! -w "$FILES") {
    warn qq{Directory "$FILES" is not writable!\n};
}
my $URL_FREEBSD = $ENV{URL_FREEBSD};
my $URL_INDEX = $URL_FREEBSD."/INDEX";
my $URL_PACKAGES = $URL_FREEBSD."/All";

# extension of package filenames (tgz for <= 4.x, tbz for >= 5.x)
$URL_FREEBSD =~ m/(\d+)\.\d+-RELEASE/;
my $EXT = $+ ? ($+ >= 5 ? "tbz" : "tgz") : "tgz";

sub usage {
    $0 =~ m|[^/]+$|;
    print <<EOF
Usage: $& [OPTION]... ARG...

A package manager for FreeBSD emulating some of the functionality of apt-get

Options:
  -i, --install      Install matching package files
  -r, --remove       Remove matching package files
  -f, --fetch        Fetch matching package files
  -t, --test         Test only
  -n, --name         Match only package name
  -d, --description  Match only package description
  -s, --silent       Silent mode
  -v, --verbose      Increase output verbosity
      --index        Fetch index from homepage

  -h, --help         Print this help and exit

Package index file: $INDEX
Directory containing package files: $FILES
Package index URL: $URL_INDEX
Packages base URL: $URL_PACKAGES

Note: package commands are done by pkg_info, pkg_add, pkg_delete, etc...
EOF
    ;
    exit 1;
}

sub fetch_index {
    print `wget -c $URL_INDEX -O $INDEX`;
    chmod 0444, $INDEX;
}

my (%pkg_db, %depend_db);
open(F, $INDEX) || die qq{Could not open index file: $INDEX\nUse the --index flag to fetch the index file from $URL_INDEX\n};
if ($action eq "INSTALL" || $action eq "FETCH") {
    while (<F>) {
        my @attributes = split(/\|/);
        $pkg_db{$attributes[0]} = \@attributes;
    }
    my @matches;
    foreach my $arg (@args) {
        push(@matches, grep(m/$arg/i, keys(%pkg_db))) 
            if $match eq "NAME" || $match eq "BOTH";
        push(@matches, grep($pkg_db{$_}->[3] =~ m/$arg/i, keys(%pkg_db))) 
            if $match eq "DESCRIPTION" || $match eq "BOTH";
    }
    foreach my $pkg (@matches) {
        @targets = ();
        @targets_fix = ();
        &print_depend(0, $pkg);
        next unless @targets;
        &do_action(@{$pkg_db{$pkg}}) if &confirm_action($action, @targets);
    }
} else {
    while (<F>) {
        chop;
        my @attributes = split(/\|/);
        for (@args) {
            my $matching = 0;
            if ($match eq 'NAME') {
                $matching = 1 if $attributes[0] =~ m/$_/i;
            } elsif ($match eq 'DESCRIPTION') {
                $matching = 1 if $attributes[3] =~ m/$_/i;
            } elsif ($match eq 'BOTH') {
                $matching = 1 if ($attributes[0] =~ m/$_/i || $attributes[3] =~ m/$_/i);
            }
            if ($matching) {
                &do_action(@attributes);
                last;
            }
        }
    }
}
close(F);

sub print_depend {
    my ($level, $pkg) = @_;
    if (system(qq{pkg_info "$pkg" >/dev/null 2>/dev/null}) == 0) {
        push(@targets_fix, $pkg) unless grep($_ eq $pkg, @targets_fix) || -f "$FILES/$pkg.$EXT";
        if ($level == 0 || $verbosity > 0) {
            print "  ";
            print "  " x $level;
            print "$pkg => ";
            print "Installed\n";
        }
    } else {
        print "* ";
        print "  " x $level;
        print "$pkg => ";
        print "NOT installed\n";
        push(@targets, $pkg) unless grep($_ eq $pkg, @targets);
        if ($depend_db{$pkg}) {

        } elsif (my $depend_list = join(" ", grep($_ ne "", @{$pkg_db{$pkg}}[7, 8]))) {
            my @depend;
            for (split(/ /, $depend_list)) {
                my $this = $_;
                push(@depend, $this) unless grep($_ eq $this, @depend);
            }
            $depend_db{$pkg} = \@depend;
            foreach my $dep (@depend) {
                &print_depend($level + 1, $dep);
            }
        }
    }
}

sub confirm_action {
    my ($action, @list) = @_;
    print "action: $action ".join(", ", @list)." [Y/n] ";
    chomp(my $ans = <STDIN>);
    return $ans eq "" || $ans =~ m/^y/i;
}

sub do_action {
    my @attributes = @_;
    if (! $verbosity && ! $action) {
        print $attributes[0], "\n";
    } elsif ($verbosity < 0) {
    } elsif ($verbosity == 1) {
        print qq{Package: $attributes[0]\n};
        print qq{Description: $attributes[3]\n};
        print qq{Homepage: $attributes[9]\n} if $attributes[9];
        print qq{\n};
    } elsif ($verbosity == 2) {
        print qq{Package: $attributes[0]\n};
        print qq{Description: $attributes[3]\n};
        print qq{Homepage: $attributes[9]\n} if $attributes[9];
        print qq{Category: $attributes[6]\n};
        print qq{Location: $attributes[1]\n};
        print qq{Depends (1): $attributes[7]\n} if $attributes[7];
        print qq{Depends (2): $attributes[8]\n} if $attributes[8];
        print qq{\n};
    } elsif ($verbosity >= 3) {
        print join('|', @attributes), "\n";
    }
    if ($action eq "INSTALL") {
        &do_fetch();
        &do_install($attributes[0]);
    } elsif ($action eq "REMOVE") {
        &do_remove($attributes[0]);
    } elsif ($action eq "FETCH") {
        &do_fetch();
    }
}

sub do_install {
    my $pkg = shift(@_);
    if (system(qq{pkg_info "$pkg" >/dev/null 2>/dev/null}) == 0) {
        print qq{Package $pkg is already installed.\n} if $verbosity > 0;
        return;
    }
    print qq{Installing $pkg ...\n};
    foreach my $dep (@{$depend_db{$pkg}}) {
        &do_install($dep);
    }
    system(qq{pkg_add $FILES/$pkg.$EXT});
    print qq{Installing $pkg ... DONE.\n};
}

sub do_remove {
    my $name = shift(@_);
    system(qq{if pkg_info $name >/dev/null 2>/dev/null ; then echo Removing package $name ...; pkg_delete $name; else echo Package $name is not installed.; fi});
}

sub do_fetch {
    foreach my $name (@targets) {
        if (! -f "$FILES/$name.$EXT") {
            print qq{Fetching $name ...\n};
            if (system("wget -qO $FILES/$name.$EXT $URL_PACKAGES/$name.$EXT >/dev/null 2>/dev/null")) {
                unlink "$FILES/$name.$EXT";
                die "ERROR: $name could not be fetched! Exit.\n";
            }
        }
    }
    foreach my $name (@targets_fix) {
        if (! -f "$FILES/$name.$EXT") {
            print qq{Fetching missing $name ...\n};
            if (system("wget -qO $FILES/$name.$EXT $URL_PACKAGES/$name.$EXT >/dev/null 2>/dev/null")) {
                unlink "$FILES/$name.$EXT";
                warn "WARN: $name could not be fetched! Skip.\n";
            }
        }
    }
}
