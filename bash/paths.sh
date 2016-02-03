#!/bin/sh
#
# SCRIPT: paths.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2015-11-20
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Transform the display of path strings
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
    echo Transform the display of path strings
    echo
    echo Options:
    echo "  -p, --path               Print elements of \$PATH, default = $path"
    echo "  -l, --left COUNT         Print $left path segments at the left"
    echo "  -r, --right COUNT        Print $right path segments at the right"
    echo "      --dos                Convert paths to DOS format, default = $dos"
    echo "  -u, --unix               Convert paths to UNIX format, default = $unix"
    echo
    echo "  -h, --help               Print this help"
    echo
    exit 1
}

args=
left=1
right=1
path=off
dos=off
unix=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    -p|--path) path=on ;;
    --dos) dos=on ;;
    -u|--unix) unix=on ;;
    -l|--left) shift; left=$1 ;;
    -r|--right) shift; right=$1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -) usage "Unknown option: $1" ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

#eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

if test $path = on; then
    echo $PATH | perl -ne 'chomp; print map { "$_\n" } split(/:/)'
elif test $dos = on; then
    tr / \\
elif test $unix = on; then
    tr \\ /
else
    awk -v left=$left -v right=$right -F/ '{
        if (NF == 1) {
            print
        } else {
            path = ""
            for (i = 1; i <= left; ++i) {
                path = path $i "/"
            }
            path = path ".../"
            for (i = NF - right + 1; i < NF; ++i) {
                path = path $i "/"
            }
            print path $NF
        }
    }'
fi
