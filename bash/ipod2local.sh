#!/bin/sh
#
# SCRIPT: ipod2local.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2008-12-24
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Auto-detect mp3 files in ipod directories and copy with proper
#	   names in configurable directory structure.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

if type id3v2 >/dev/null 2>/dev/null; then
    have_id3v2=yes
fi

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... source target"
    echo
    echo Import mp3 files from ipod to hard disk
    echo
    echo "  -h, --help         Print this help"
    echo
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
#    --no-flag) flag=off ;;
#    -p|--param) shift; param=$1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

test $# = 2 || usage Error: specify both source and target directories.

source="$1"
target="$2"

test -d "$source" || usage Error: source directory "'$source'" does not exist.

mkdir -p "$target"

workfile=/tmp/$(basename $0)-$$
trap 'rm -f $workfile; exit 1;' 1 2 3 15

cnt=0

find "$source" -type f | while read f; do
    echo processing file: $f ...
    case $f in
	*.mp3)
	    ddd=mp3
	    if test "$have_id3v2"; then
		mkdir -p "$target/$ddd"
		echo "  -> capturing id3 tags ..."
		id3v2 -l "$f" >$workfile

		genre=$(cat $workfile | grep ^TCON | sed -e 's/^.*: //' -e 's/ (.*//')
		test "$genre" || genre=$(cat $workfile | grep -o Genre:.* | sed -e 's/^.*: //' -e 's/ (.*//')
		test "$genre" || genre=Unknown

		artist=$(cat $workfile | grep ^TPE1 | sed -e 's/^.*: //')
		test "$artist" || artist=$(cat $workfile | grep -o Artist:.* | sed -e 's/^.*: //' -e 's/  *$//')
		test "$artist" || artist=Unknown

		album=$(cat $workfile | grep ^TAL | sed -e 's/^.*: //')
		test "$album" || album=$(cat $workfile | grep -o Album..:.* | cut -f2 -d: | sed -e 's/[a-zA-Z]*$//' -e 's/^  *//' -e 's/  *$//')
		test "$album" || album=Unknown

		track=$(cat $workfile | grep ^TRCK | sed -e 's/^.*: //' -e 's?/.*??')
		test "$track" || track=$(cat $workfile | grep -o Track:.* | sed -e 's/^.*: //' -e 's/  *$//')
		test "$track" || track=0
		track=$(printf %02d $track)

		title=$(cat $workfile | grep ^TIT | cut -f2 -d: | sed -e 's/^ *//')
		test "$title" || title=$(cat $workfile | grep -o Title..:.* | cut -f2 -d: | sed -e 's/[a-zA-Z]*$//' -e 's/^  *//' -e 's/  *$//')
		test "$title" || { cnt=$((cnt+1)); title=Unknown-$(printf %03d $cnt); }

		mkdir -p "$target/$ddd/$genre/$artist/$album"
		cp "$f" "$target/$ddd/$genre/$artist/$album/$track - $title.mp3"
		echo "  -> saved as '$target/$ddd/$genre/$artist/$album/$track - $title.mp3'"
	    else
		sourcepath=$(echo $f | sed -e "s?^$source/??")
		sourcedirname=$(dirname "$sourcepath")
		mkdir -p "$target/$ddd/$sourcedirname"
		cp "$f" "$target/$ddd/$sourcedirname"
		echo "  -> saved in '$target/$ddd/$sourcedirname'"
	    fi
	    echo
	    ;;
	*.m4a)
	    sourcepath=$(echo $f | sed -e "s?^$source/??")
	    sourcedirname=$(dirname "$sourcepath")
	    ddd=m4a
	    mkdir -p "$target/$ddd/$sourcedirname"
	    cp "$f" "$target/$ddd/$sourcedirname"
	    echo "  -> saved in '$target/$ddd/$sourcedirname'"
	    echo
	    ;;
	*)
	    sourcepath=$(echo $f | sed -e "s?^$source/??")
	    sourcedirname=$(dirname "$sourcepath")
	    ddd=m__
	    mkdir -p "$target/$ddd/$sourcedirname"
	    cp "$f" "$target/$ddd/$sourcedirname"
	    echo "  -> saved in '$target/$ddd/$sourcedirname'"
	    echo
	    ;;
    esac
done
