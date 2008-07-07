#!/bin/sh
#
# SCRIPT: svn-cleanse.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2007-05-23
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Remove .svn directories from the specified directory subtree.
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
    echo "usage: `basename $0` [-h|--help]"
    exit
}

args=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    --) shift; for i; do args="$args \"$i\""; done; shift $# ;;
    -?*) echo Unknown option: $1 ; usage ;;
    *) args="$args \"$1\"" ;;
    esac
    shift
done

eval "set -- $args"

test $# = 0 && usage

find "$@" -name .svn -print0 | xargs -0 rm -frv

# eof
