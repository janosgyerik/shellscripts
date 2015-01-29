#!/bin/sh
#
# SCRIPT: install.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2011-08-24
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Install the scripts into your ~/bin directory.
#   If ~/bin exists, symlinks will be created in there.
#   Otherwise the target directory must be specified explicitly.
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
    echo "Install the scripts into your ~/bin directory"
    echo
    echo Options:
    echo "  -d, --dir DIR  The target directory to install into, default = $dir"
    echo "  -l, --link     Use symlinks, default = $link"
    echo "  -c, --copy     Copy instead of symlinks, default = ! $link"
    echo "  -u, --update   Replace existing files, default = $update"
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
update=off
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
    -u|--update) update=on ;;
    --no-update) update=off ;;
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

mkdir -p "$dir"
absdir=$(cd "$dir"; pwd)

cd $(dirname "$0")

for script in bash/*.sh perl/*.pl awk/*.awk python/*.py; do
    echo $script | grep ^_ >/dev/null && continue

    source=$PWD/$script
    target=$absdir/$(basename "$script")

    if test $update = on; then
        test -f "$target" -o -L "$target" && echo rm -f "$target" && rm -f "$target"
    fi

    if ! test -f "$target" -o -L "$target"; then
        if test $link = on; then
            echo link $target to $source
            ln -snf "$source" "$target"
        else
            echo copy to $target from $source
            cp "$source" "$target"
        fi
    fi
done
