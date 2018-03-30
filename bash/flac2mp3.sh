#!/bin/sh
#
# Convert .flac files to .mp3 with flac and lame.
#

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$@"
        exitcode=1
    fi
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo "Convert FLAC files to MP3 using flac and lame"
    exit $exitcode
}

args=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
    esac
    shift
done

eval "set -- $args"

require="flac lame"
failed=no
for program in $require; do
    if ! type $program 2>/dev/null >/dev/null; then 
	echo "Error: the program '$program' is not installed or not in PATH"
	failed=yes
    fi
done
test $failed = no || exit 1

for i; do
    echo "flac -c -d \"$i\" | lame -m j -b 192 -s 44.1 - \"${i%.flac}.mp3\""
    flac -c -d "$i" | lame -m j -b 192 -s 44.1 - "${i%.flac}.mp3"
done
