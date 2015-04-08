#!/bin/sh
#
# SCRIPT: save-flash-linux.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
#	  with additions by David Bobb <zeroangelmk1@gmail.com>
# DATE:   2015-04-08
# REV:    1.1.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Linux only
#
# PURPOSE: Locate and copy a flash movie (youtube.com, etc) cached by a browser.
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
    echo 'Copy a flash movie (youtube.com, etc) saved by a browser in /private'
    echo
    echo Options:
    echo "  -n, --number NUMBER	default = $number"
    echo
    echo "  -a, --audio		Save as MP3 File (requires ffmpeg)"
    # Note: Audio is hardcoded to FFMPEG Quality 2 for now
    echo
    echo "  -h, --help		Print this help"
    echo
    exit 1
}

args=
#arg=
#flag=off
#param=
number=
aquality=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    --no-flag) flag=off ;;
#    -p|--param) shift; param=$1 ;;
    -n|--number) shift; number=$1 ;;
    -a|--audio) aquality=2 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -) usage "Unknown option: $1" ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

#test $# -gt 0 || usage

files=$(file /proc/*/fd/* 2>/dev/null | grep Flash | cut -f1 -d:)

if test "$files"; then
    if test "$1"; then
	test "$number" || number=1
	file=$(ls $files | sed -ne "$number p")
	if test "$aquality"; then
	ffmpeg -i "$file" -q:a $aquality -vn "$1"
	else
	cp "$file" "$1" && echo "cp $file $1" && file "$1"
	fi
    else
	# Print the filesizes beside the flash streams when listing
	wc -c $files | awk '{ filesize = $1 / 1024 / 1024; filepath = $2; printf("%s (%3.1f MB)\n", filepath, filesize) }'
	# ls -1 $files
    fi
fi

# eof
