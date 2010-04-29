#!/bin/sh
#
# Convert .flac files to .mp3 with flac and lame.
#

usage() {
    test "$1" && echo $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo "Convert FLAC files to MP3 using flac and lame"
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

require="flac lame"
failed=no
for program in $require; do
    if ! type $program 2>/dev/null >/dev/null; then 
	echo "Error: the program '$program' is not installed or not in PATH"
	failed=yes
    fi
done
test $failed = no || exit 1

for i in "$@"; do
    echo "flac -c -d \"$i\" | lame -m j -b 192 -s 44.1 - \"${i%.flac}.mp3\""
    flac -c -d "$i" | lame -m j -b 192 -s 44.1 - "${i%.flac}.mp3"
done

# end of script
