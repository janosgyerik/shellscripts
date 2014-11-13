#!/bin/sh
#
# SCRIPT: find-recent.sh
# AUTHOR: Janos Gyerik <janos@axiom>
# DATE:   2013-09-13
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Find and sort files by atime/ctime/mtime
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
    echo Find and sort files by atime/ctime/mtime
    echo
    echo Options:
    echo "  -d, --days DAYS            Filter by most recent days, default = $days"
    echo "  -a, --atime                Use atime, default = $time"
    echo "  -m, --mtime                Use mtime, default = $time"
    echo "  -c, --ctime                Use ctime, default = $time"
    echo "  -r, --reverse              Reverse the sorting order, default = $reverse"
    echo "      --maxdepth MAXDEPTH    Maximum depth to go, default = $maxdepth"
    echo "      --mindepth MINDEPTH    Minimum depth to go, default = $mindepth"
    echo "      --cmd                  Command to run for each file, default = $cmd"
    echo "  -v, --verbose              Verbose output, default = $reverse"
    echo
    echo "  -h, --help                 Print this help"
    echo
    exit 1
}

args=
days=7
time=atime
reverse=off
verbose=off
maxdepth=
mindepth=
cmd=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    -d|--days) shift; days=$1 ;;
    -a|--atime) time=atime ;;
    -m|--mtime) time=mtime ;;
    -c|--ctime) time=ctime ;;
    -r|--reverse) reverse=on ;;
    --maxdepth) shift; maxdepth=$1 ;;
    --mindepth) shift; mindepth=$1 ;;
    --cmd) shift; cmd=$1 ;;
    -v|--verbose) verbose=on ;;
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

test $# -gt 0 || usage

uname | grep Linux >/dev/null && linux=1 || linux=

if test ! "$cmd"; then
    case $time in
        atime) test "$linux" && cmd='ls -lu --sort=time' || cmd='ls -ltu' ;;
        mtime) cmd='ls -lt' ;;
        ctime) test "$linux" && cmd='ls -lc --sort=time' || cmd='ls -ltU' ;;
    esac
    test $reverse = on && cmd="$cmd -r"
fi

test $reverse = on && days=+$days || days=-$days
test "$maxdepth" && op_maxdepth="-maxdepth $maxdepth"
test "$mindepth" && op_mindepth="-mindepth $mindepth"

op_find="-type f -$time $days $op_maxdepth $op_mindepth -print0"

test $verbose = on && echo "# find . $op_find | xargs -0 $cmd"

for i; do
    find $i $op_find | xargs -0 $cmd
done
