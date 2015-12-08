#!/bin/sh
#
# SCRIPT: ssh-authorizeme.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2010-05-29
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Add a public key to the authorized_keys file on a remote server.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          

usage() {
    test "$1" && echo Error: $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo Add a public key to the authorized_keys file on a remote server
    echo
    echo Options:
    echo '  -f, --file FILE     Public key file to use, default = '$file
    echo
    echo '  -h, --help          Print this help'
    exit 1
}

args=
#arg=
#flag=off
#param=
file=~/.ssh/id_rsa.pub
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -f|--file) shift; file=$1 ;;
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

test -f "$file" || usage no such file: $file

errors=

for remote in "$@"; do
    echo '* 'adding $file to $remote:.ssh/authorized_keys ...
    if ssh $remote 'mkdir -p .ssh; cat >> .ssh/authorized_keys; chmod -R go-rwx .ssh' < $file; then
	if ssh-add -L >/dev/null; then
	    echo '* 'running ssh $remote "'date; hostname'" to verify ...
	    ssh $remote 'date; hostname; uptime; uname -a' || errors=yes
	else
	    errors=yes
	fi
    else
	errors=yes
    fi
done

test ! $errors
