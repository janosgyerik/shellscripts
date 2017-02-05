#!/usr/bin/env bash
#
# SCRIPT: template-pl.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2007-05-30
# REV:    1.0.T (Valid are A, B, D, T and P)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Generate a Perl script template with a simple command line parser.
#          Note: the program intentionally doesn't handle flags/params
#          with funny characters in them. You should make simple, easy to use
#          flags/params anyway.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          

usage() {
    test $# = 0 || echo "$@"
    echo "Usage: $0 [OPTION]... FILENAME"
    echo
    echo Generate a Perl script template with a simple argument parser
    echo
    echo Options:
    echo "  -a, --author AUTHOR     Name of the author, default = $author"
    echo "  -d, --description DESC  Description of the script, default = $description"
    echo "  -f, --flag FLAG         A parameter that takes no arguments"
    echo "  -p, --param PARAM       A parameter that takes one argument"
    echo
    echo "  -h, --help              Print this help"
    echo
    exit 1
}

set_longest() {
    len=${#1}
    test $len -gt $longest && longest=$len
}

set_padding() {
    len=${#1}
    padding=$(printf %$((width - len))s '')
}

#flag=off
#param=
#args=
test "$AUTHOR" && author=$AUTHOR || author="$(id -un) <$(id -un)@$(hostname)>"
longest=5
description='BRIEF DESCRIPTION OF THE SCRIPT'
# options starting with "f" are flags, "p" are parameters.
options=
file=
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    --no-flag) flag=off ;;
#    -p|--param) shift; param=$1 ;;
    -a|--author) shift; author=$1 ;;
    -d|--description) shift; description="$1" ;;
    -f|--flag) shift; options="$options f$1"; set_longest $1 ;;
    -p|--param) shift; options="$options p$1"; set_longest $1 ;;
#    --) shift; while test $# != 0; do args="$args \"$1\""; shift; done; break ;;
#    -) usage "Unknown option: $1" ;;
    -?*) usage "Unknown option: $1" ;;
#    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
    *) file=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

test "$file" || usage

#  -p, --param PARAM  A parameter that takes no arguments
#^^^^^^^8^^^^L^^^^^L^^
width=$((8 + longest + 2 + longest))
test $width -gt 40 && width=40

if test "$file" != "-"; then
    [[ "$file" == *.pl ]] || file="$file".pl
else
    file=/tmp/.template-perl.$$
    test=1
fi
echo "Creating \"$file\" ..."

trap 'rm -f "$file"; exit 1' 1 2 3 15

cat << EOF > "$file"
#!/usr/bin/env perl
#
# SCRIPT: $(basename "$file")
# AUTHOR: $author
# DATE:   $(date +%F)
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
# PLATFORM: Linux only
# PLATFORM: FreeBSD only
#
# PURPOSE: $description
#

use strict;
use warnings;

my @args;
#my $arg = '';
#my $flag = '';
#my $param = '';
EOF

for i in $options; do 
    f=${i:0:1}
    name=${i:1}
    vname=${name//-/_}
    oname=${name//_/-}
    test $f = f && echo "my \$$vname = '';" >> "$file" || echo "my \$$vname = '';" >> "$file"
done

cat << EOF >> "$file"

OUTER: while (@ARGV) {
    for (shift(@ARGV)) {
        (\$_ eq '-h' || \$_ eq '--help') && do { &usage(); };
EOF

# an example entry to illustrate parsing a flag
echo "        # (\$_ eq '-f' || \$_ eq '--flag') && do { \$flag = 1; last; };" >> "$file"
# an example entry to illustrate parsing a param
echo "        # (\$_ eq '-p' || \$_ eq '--param') && do { \$param = shift(@ARGV); last; };" >> "$file"

for i in $options; do 
    f=${i:0:1}
    name=${i:1}
    vname=${name//-/_}
    oname=${name//_/-}
    first=${name:0:1}
    if test $f = f; then
        # this is a flag
        echo "        (\$_ eq '-$first' || \$_ eq '--$oname') && do { \$$vname = 1; last; };" >> "$file"
        echo "        (\$_ eq '--no-$oname') && do { \$$vname = ''; last; };" >> "$file"
    else
        # this is a param
        echo "        (\$_ eq '-$first' || \$_ eq '--$oname') && do { \$$vname = shift(@ARGV); last; };" >> "$file"
    fi
done

cat << "EOF" >> "$file"
        ($_ eq '--') && do { push(@args, @ARGV); undef @ARGV; last; };
        ($_ =~ m/^-.+/) && do { &usage("Unknown option: $_"); };
        push(@args, $_);  # script that takes multiple arguments
        # $arg ? $arg = $_ : &usage();  # strict with excess arguments
        # $arg = $_;  # forgiving with excess arguments
    }
}

sub bool2string() {
    return $_[0] ? "true" : "false";
}

sub usage() {
    print @_, "\n" if @_;
    $0 =~ m/[^\/]+$/;
    print "Usage: $& [OPTION]... [ARG]...\n\n";
EOF
cat << EOF >> "$file"
    print "$description\n";
    print "\nOptions:\n";
EOF

for i in $options; do 
    f=${i:0:1}
    name=${i:1}
    vname=${name//-/_}
    oname=${name//_/-}
    first=${name:0:1}

    if test $f = f; then
        # this is a flag
        optionstring="  -$first, --$oname"
        echo Adding flag: $optionstring
        set_padding "$optionstring"
        echo "    print \"$optionstring$padding default = \".&bool2string(\$$vname).\"\n\";" >> "$file"
        optionstring="      --no-$oname"
        echo Adding flag: $optionstring
        set_padding "$optionstring"
        echo "    print \"$optionstring$padding default = ! \".&bool2string(\$$vname).\"\n\";" >> "$file"
    else
        # this is a param
        pname=$(echo $oname | tr a-z- A-Z_)
        optionstring="  -$first, --$oname $pname"
        echo Adding param: $optionstring
        set_padding "$optionstring"
        echo "    print \"$optionstring$padding default = \$$vname\n\";" >> "$file"
    fi
done

helpstring="  -h, --help"
set_padding "$helpstring"
cat << EOF >> "$file"
    print "\\n";
    print "$helpstring$padding Print this help\\n";
    print "\\n";
    exit(1);
}

&usage() unless @args;
EOF

chmod +x "$file"
test "$test" && cat "$file"
