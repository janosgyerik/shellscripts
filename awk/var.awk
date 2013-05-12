#!/bin/sh
#
# SCRIPT: var.awk
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2004-12-16
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Compute the variance of numeric values in the input files or pipe. 
#	   One number per line is expected in the input.
#

usage() {
    test "$1" && echo $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo Compute the variance of numeric values in the input files or pipe. 
    exit 1
}

args=
#arg=
#flag=off
#param=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"

#test -f "$1" || usage

usage () {
    echo "usage: `basename $0` [-h|--help] file"
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

#test $# -gt 0 || usage

awk -v sqsum=0 -v sum=0 -v nr=0 '
/^[0-9.]/ { sum += $0; sqsum += $0 * $0; ++nr; }
END { 
    avg = sum / nr; 
    print sqsum / nr - avg * avg;
}
' $@

# eof
