#!/bin/sh
#
# SCRIPT: unrar.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-05-29
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Properly unrar files in directories containing spaces in their names.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

usage () {
    echo "Usage: $0 [OPTION]... [FILE]..."
    echo
    echo Properly unrar files in directories containing spaces in their names
    echo
    echo "  -h, --help       Print this help"
    echo "  -v, --verbose    "
    echo
    exit
}

args=
#flag=off
#param=
verbose=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -v|--verbose) verbose=on ;;
    --) shift; for i; do args="$args \"$i\""; done; shift $# ;;
    -?*) echo Unknown option: $1 ; usage ;;
    *) args="$args \"$1\"" ;;
    esac
    shift
done

eval "set -- $args"

test $# -gt 0 || usage

for i; do
    rar v "$i" | sed -ne '/^-/,/^-/ p' | sed -ne '2~2 p' | sed -e '/^-/ d' -e 's/ //' | \
    while read filename; do 
	dir=`dirname "$filename"`
	mkdir -p "$dir"
	test -d "$filename" && continue
	cmd='rar e "$i" "$filename" "$dir"'
	if [ $verbose = on ]; then 
	    eval $cmd
	else
	    eval $cmd | grep "^Extracting  "
	fi
    done
done
