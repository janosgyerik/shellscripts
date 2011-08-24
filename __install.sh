#!/bin/sh
#
# SCRIPT: __install.sh
# AUTHOR: Janos Gyerik <info@titan2x.com>
# DATE:   2011-08-24
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Install the scripts into the user's home directory.
#	   If ~/bin exists, symlinks will be created in there.
#	   Otherwise the target directory must be specified explicitly.
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
    echo "Install the scripts into the user's home directory."
    echo
    echo Options:
    echo "  -d, --dir DIR  The target directory to install into, default = $dir"
    echo "  -l, --link     Use symlinks, default = $link"
    echo "  -c, --copy     Copy instead of symlinks, default = ! $link"
    echo
    echo "  -h, --help     Print this help"
    echo
    exit 1
}

args=
#arg=
#flag=off
#param=
dir=
link=on
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    --no-flag) flag=off ;;
#    -p|--param) shift; param=$1 ;;
    -d|--dir) shift; dir=$1 ;;
    -l|--link) link=on ;;
    --no-link) link=off ;;
    -c|--copy) link=off ;;
    --no-copy) link=on ;;
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

test "$dir" || dir=~/bin

test -d "$dir" || usage 'Use -d DIR to specify target directory!'

absdir=$(cd "$dir"; pwd)

cd $(dirname "$0")

for f in *.sh *.pl *.awk; do
    echo $f | grep ^_ >/dev/null && continue

    script=$PWD/$f
    target=$absdir/$f

    test -f "$target" && echo rm -f $target && rm -f "$target"

    if test $link = on; then
	echo link $target to $script
	ln -snf "$script" "$target"
    else
	echo copy to $target from $script
	cp "$target" "$script"
    fi
done

# eof
