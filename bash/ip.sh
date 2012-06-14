#!/bin/sh
#
# SCRIPT: ip.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2010-05-25
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Linux, BSD
#
# PURPOSE: print the IP address of the local host
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          

usage() {
    test "$1" && echo $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo Print the IP address of the local host
    echo
    echo Options:
    echo '  -4, --ip4     Get IPv4 address'
    echo '  -6, --ip6     Get IPv6 address'
    echo
    echo '  -a, --all     Get all IPv4 or IPv6 addresses'
    echo
    echo '  -h, --help    Print this help'
    echo
    exit 1
}

args=
#arg=
#flag=off
#param=
inet=inet
all=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -4|--ip4) inet=inet ;;
    -6|--ip6) inet=inet6 ;;
    -a|--all) all=on ;;
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

if test $all = on; then
    ifconfig | grep $inet' ' | sed -e "s/.*$inet //" -e 's/^addr: *//' -e 's/ .*//'
elif test "$1"; then
    for iface in "$@"; do
	ifconfig $iface | grep $inet' ' | sed -n -e "s/.*$inet //" -e 's/^addr: *//' -e 's/ .*//' -e '1 p'
    done
else
    ifconfig | grep $inet' ' | sed -n -e "s/.*$inet //" -e 's/^addr: *//' -e 's/ .*//' -e '1 p'
fi

# eof
