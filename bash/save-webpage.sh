#!/bin/sh
#
# SCRIPT: save-webpage.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2008-06-21
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Save a webpage and all the files necessary to display properly.
#	   The script is merely a shortcut to wget with appropriate options.
#	   Note: at the moment this doesn't work very well... 
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo Save a webpage and all the files necessary to display properly
    echo
    echo "  -u, --user USER     Username to login, default = $username"
    echo "  -p, --pass PASS     Password to login, default = $password"
    echo
    echo "  -d, --dir DIR       Directory to save files, default = $dir"
    echo
    echo "  -h, --help          Print this help"
    echo
    exit 1
}

args=
#arg=
#flag=off
#param=
username=
password=
dir=webpage
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -u|--user) shift; username=$1 ;;
    -p|--pass) shift; password=$1 ;;
    -d|--dir) shift; dir=$1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

test $# -gt 0 || usage

wget -c -H -k -K -p -P $dir --user "$username" --password "$password" "$1"

grep -ro 'url(.*)' $dir | sort | uniq | while read line; do
    file=$(echo $line | grep -o '(.*)' | tr -d '() ')
    basedir=$(echo $line | cut -f1 -d: | sed -e 's?[^/]*$??')
    url=http://$(echo $basedir | cut -f2- -d/)$file
    out=$basedir$file
    mkdir -p $(dirname $out)
    wget -c -O $out $url
done
