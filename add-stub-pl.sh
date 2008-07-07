#!/bin/sh
#
# SCRIPT: add-stub-pl.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2005-01-27
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Non platform dependent
#
# PURPOSE: Add a stub template to an existing Perl script.
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

usage () {
    echo "usage: `basename $0` [-h|--help] [-a|--author author] script1 [script2, ...]"
    exit
}

args=
test "$AUTHOR" && author=$AUTHOR || author='AUTHOR <email@address.com>'
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    -a|--author) shift; author=$1 ;;
    --) shift; for i; do args="$args \"$i\""; done; shift $# ;;
    -?*) echo Unknown option: $1 ; usage ;;
    *) args="$args \"$1\"" ;;
    esac
    shift
done

eval "set -- $args"

test $# = 0 && usage

tmp=/tmp/.add-stub-pl.$$
for i; do
    echo Adding stub to $i ...
    > $tmp
    head -1 $i >> $tmp
    cat << EOF >> $tmp
#
# SCRIPT: `basename "$i"`
# AUTHOR: $author
# DATE:   `date --iso`
# REV:    1.0.T (Valid are A, B, D, T and P)
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
    tail +2 $i >> $tmp
    cp $tmp $i
done

# eof
