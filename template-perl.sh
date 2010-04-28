#!/bin/sh
#
# SCRIPT: template-pl.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2007-05-30
# REV:    1.0.T (Valid are A, B, D, T and P)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Generate the skeleton of a shell script, with the capability to
#          process "flags" and "params". Here, "flag" means option without
#          arguments, and "param" means option with one argument.
#          Note: the program (intentionally) does not handle flags/params
#          with funny characters in them. You should make simple, easy to use
#          flags/params anyway.
#
# REV LIST:
#        DATE:	DATE_of_REVISION
#        BY:	AUTHOR_of_MODIFICATION   
#        MODIFICATION: Describe what was modified, new features, etc-
#
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... FILENAME"
    echo
    echo "Generate the template of a Bourne shell script that can parse simple parameters."
    echo
    echo "  -a, --author AUTHOR   Name of the author, default = $author"
    echo "  -f, --flag FLAG       A parameter that takes no arguments"
    echo "  -p, --param PARAM     A parameter that takes one argument"
    echo "      --stub            Add a 'stub' to the top of the script, default = $stub"
    echo
    echo "  -h, --help            Print this help"
    echo
    exit 1
}

set_longest() {
    l=`echo $1 | wc -c`
    test $l -gt $longest && longest=$l
}

#flag=off
#param=
#args=
test "$AUTHOR" && author=$AUTHOR || author='AUTHOR <email@address.com>'
stub=off
longest=5
# options starting with "f" are flags, options starting with "p" are parameters.
options=
file=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -a|--author) shift; author=$1 ;;
    --stub) stub=on ;;
    -f|--flag) shift; options="$options f$1"; set_longest $1 ;;
    -p|--param) shift; options="$options p$1"; set_longest $1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
#    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
    *) file=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

test "$file" || usage

width=`expr 8 + $longest + 1 + $longest - 2`

if [ "$file" != "-" ]; then 
    test `expr "$file" : '.*\.pl$'` = 0 && file="$file.pl"
else
    file=/tmp/.template-perl.$$
    test=1
fi
echo Creating \"$file\" ...

trap 'rm -f "$file"; exit 1' 1 2 3 15

echo '#!/usr/bin/perl' > "$file"

if [ $stub = on ]; then
    cat << EOF >> "$file"
#
# SCRIPT: `basename "$file"`
# AUTHOR: $author
# DATE:   `date +%F`
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
EOF
fi

cat << "EOF" >> "$file"

use strict;
use warnings;

my @args;
#my $arg = '';
#my $flag = '';
#my $param = '';
EOF

has_flags=no
for i in $options; do 
    f=`expr $i : '\(.\)'`
    name=`expr $i : '.\(.*\)'`
    test $f = f && has_flags=yes && echo "my \$$name = '';" >> "$file" || echo "my \$$name = '';" >> "$file"
done

test $has_flags = yes && ttmp="" || ttmp="#"
cat << EOF >> $file

OUTER: while (@ARGV) {
    for (shift(@ARGV)) {
        (\$_ eq '-h' || \$_ eq '--help') && do { &usage(); };
EOF

# an example entry to illustrate parsing a flag
echo "#        (\$_ eq '-f' || \$_ eq '--flag') && do { \$flag = 1; last; };" >> "$file"
# an example entry to illustrate parsing a param
echo "#        (\$_ eq '-p' || \$_ eq '--param') && do { \$param = shift(@ARGV); last; };" >> "$file"

for i in $options; do 
    f=`expr $i : '\(.\)'`
    name=`expr $i : '.\(.*\)'`
    first=`expr $name : '\(.\)'`
    if [ $f = f ]; then
	# this is a flag
	echo "        (\$_ eq '-$first' || \$_ eq '--$name') && do { \$$name = 1; last; };" >> "$file"
    else
	# this is a param
	echo "        (\$_ eq '-$first' || \$_ eq '--$name') && do { \$$name = shift(@ARGV); last; };" >> "$file"
    fi
done

cat << "EOF" >> "$file"
        ($_ eq '--') && do { push(@args, @ARGV); undef @ARGV; last; };
        ($_ =~ m/^-.+/) && do { &usage("Unknown option: $_"); };
        push(@args, $_);  # script that takes multiple arguments
#	$arg ? $arg = $_ : &usage();  # strict with excess arguments
#	$arg = $_;  # forgiving with excess arguments
    }
}

sub usage() {
    print @_, "\n" if @_;
    $0 =~ m/[^\/]+$/;
    print "Usage: $& [OPTION]... [ARG]...\n";
    print "BRIEF DESCRIPTION OF THE SCRIPT\n";
    print "\n";
EOF

set_padding() {
    padding=
    j=`echo $1 | wc -c`
    while [ $j -lt $width ]; do
	padding="$padding "
	j=`expr $j + 1`
    done
}

for i in $options; do 
    f=`expr $i : '\(.\)'`
    name=`expr $i : '.\(.*\)'`
    first=`expr $name : '\(.\)'`

    if [ $f = f ]; then
	# this is a flag
	optionstring="  -$first, --$name"
	echo "Adding flag -$first, --$name ..."
    else
	# this is a param
	pname=`echo $name | tr a-z A-Z`
	optionstring="  -$first, --$name $pname"
	echo "Adding param -$first, --$name ..."
    fi
    set_padding "$optionstring"
    echo "    print \"$optionstring$padding default = \$$name\\n\";" >> "$file"
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

# eof
EOF

chmod +x "$file"
test "$test" && cat "$file"

# eof
