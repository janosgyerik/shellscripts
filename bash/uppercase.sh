#!/usr/bin/env bash
#
# SCRIPT: uppercase.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2004-12-23
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Rename specified files to all uppercase letters.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          
#

usage() {
    test $# = 0 || echo "$@"
    echo "Usage: $0 [OPTION]... FILE..."
    echo
    echo Rename files to all uppercase letters
    echo
    echo "  -n, --dry-run         Dry run, show what would happen"
    echo
    echo "  -h, --help            Print this help"
    echo
    exit 1
}

args=
dryrun=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    -n|--dry-run) dryrun=on ;;
    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;
    esac
    shift
done

eval "set -- $args"

test $# -gt 0 || usage

for path; do
    test -e "$path" || continue
    origfile=$(basename "$path")
    newfile=$(tr '[:lower:]' '[:upper:]' <<< "$origfile")
    origdir=$(dirname "$path")
    origpath=$origdir/$origfile
    newpath=$origdir/$newfile
    test "$origpath" != "$newpath" || continue
    echo "$path -> $newpath"
    test $dryrun = on || mv -i -- "$path" "$newpath"
done
