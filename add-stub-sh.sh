#!/bin/sh
#
# SCRIPT: add-stub-sh.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2004-11-27
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Non platform dependent
#
# PURPOSE: Insert a stub template after the first line of a shell script.
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
    echo "Usage: $0 [OPTION]... [FILE]..."
    echo "Insert a stub template after the first line of a shell script."
    echo
    echo "  -h, --help            Print this help"
    echo
    exit 1
}

args=
#flag=off
#param=
test "$AUTHOR" && author=$AUTHOR || author='AUTHOR <email@address.com>'
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -a|--author) shift; author=$1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"

test $# = 0 && usage

tmp=/tmp/.add-stub-sh.$$
trap 'rm -f $tmp; exit 1' 1 2 3 15

for i in "$@"; do
    echo Adding stub to $i ...
    > $tmp
    head -1 "$i" >> $tmp
    cat << EOF >> $tmp
#
# SCRIPT: $(basename "$i")
# AUTHOR: $author
# DATE:   $(date +%F)
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
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          
EOF
    tail +2 "$i" >> $tmp
    cp $tmp "$i"
done

rm -f $tmp

# eof
