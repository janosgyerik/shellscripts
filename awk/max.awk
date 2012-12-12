#!/bin/sh
#
# SCRIPT: max.awk
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2004-12-16
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Find the maximum numeric value in the input files or pipe. 
#

usage() {
    test "$1" && echo $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo Find the maximum numeric value in the input files or pipe. 
    echo
    echo Options:
    echo "  -c, --col COL       Column to use, default=$col"
    echo
    echo '  -h, --help          Print this help'
    exit 1
}

args=
#arg=
#flag=off
col=1
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
    -c|--col) shift; col=$1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"

#test $# -gt 0 || usage

#### tread carefully! this works in Solaris, but easy to break!
awk "BEGIN {col=$col; first=1}"'
$col ~ /^[0-9.]/ { 
    if (first == 1) {
        first = 0;
        max = $col;
    }
    else {
        if ($col > max) max = $col;
    }
}
END { print max; }
' $@

# eof
