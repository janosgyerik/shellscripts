#!/bin/sh
#
# SCRIPT: screenshot.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2010-05-15
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Take a screenshot of the entire screen or a window.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          

usage() {
    test "$1" && echo $@
    echo "Usage: $0 [OPTION]..."
    echo
    echo Take a screenshot of the entire screen or a window
    echo
    echo Options:
    echo '  -o, --out OUT       Save screenshot to OUT, default = '$out
    echo '  -w, --window        Take screenshot of a window'
    echo '  -r, --root          Take screenshot of the entire screen'
    echo
    echo '  -h, --help          Print this help'
    exit 1
}

args=
#arg=
#flag=off
#param=
xwd_param=-root
out=screenshot.xwd
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
    -w|--window) xwd_param=-frame ;;
    -r|--root) xwd_param=-root ;;
#    -p|--param) shift; param=$1 ;;
    -o|--out) shift; out=$1 ;;
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

if ! type xwd >/dev/null 2>/dev/null; then
    echo "Error: the program 'xwd' is not installed or not in PATH"
    exit 1
fi

xwd -out "$out" $xwd_param

ext=$(echo $out | grep -o ...$)
if test "$ext" != xwd; then
    if ! type mogrify >/dev/null 2>/dev/null; then
        echo "Error: the program 'mogrify' is not installed or not in PATH"
        echo To convert the screenshot file from XWD to other formats, install ImageMagick.
        exit 1
    fi
    mogrify $out
fi
