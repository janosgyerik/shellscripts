#!/bin/sh
#
# SCRIPT: gen-readme.sh
# AUTHOR: Janos Gyerik <info@titan2x.com>
# DATE:   2012-06-14
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Generate README.md file from the usage messages.
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
    echo "Generate README.md file from the usage messages."
    echo
    echo Options:
    echo "  -h, --help     Print this help"
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
    -) usage "Unknown option: $1" ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

readme=README.md
cat <<EOF >$readme
scripts-shell
-------------
My custom convenient bash, perl, awk scripts for everyday use.

All scripts print a helpful usage message with -h or --help flag.


EOF

for script in bash/*.sh perl/*.pl awk/*.awk; do
    usage=$(./$script -h | sed -ne '3 p')
    test "$usage" || usage=TODO
    cat <<EOF >>$readme
* $script

    $usage

EOF
done

# eof
