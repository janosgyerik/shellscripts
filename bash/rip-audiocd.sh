#!/bin/sh
#
# SCRIPT: rip-audiocd.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-08-26
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Copy titles in an audio CD to wav files in the specified directory.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... DIR"
    echo
    echo Copy titles in an audio CD to wav files in the specified directory
    echo
    echo "  -d, --device DEV      CDROM device to rip from"
    echo
    echo "  -h, --help            Print this help"
    echo
    exit 1
}

args=
#arg=
#flag=off
#param=
device=
dir=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -d|--device) shift; device=$1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
#    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
    *) dir=$1 ;;
    esac
    shift
done

program=cdparanoia
program_checkcd="cdparanoia -Q"
program_batch="cdparanoia -B"

if ! type $program >/dev/null 2>&1; then
    echo You need $program to rip audio CDs. Exit.
    exit
fi

test "$device" && dev_op="-d $device" || dev_op=
if ! $program_checkcd $dev_op >/dev/null 2>&1; then
    echo Unable to open disc. Exit.
    exit 1
fi

test "$dir" || usage "Specify a target directory!"

test -d "$dir" || mkdir -p "$dir"
cd "$dir"
$program_batch $dev_op

if type eject >/dev/null 2>&1; then
    eject $device
fi
