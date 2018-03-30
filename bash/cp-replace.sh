#!/bin/sh
#
# SCRIPT: cp-replace.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2004-11-28
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent (Confirmed in: Ubuntu, Git Bash)
#
# PURPOSE: Copy specified files (or files in the current directory) by
#          replacing <pattern> with (possibly empty) <replacement>.
#

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$@"
        exitcode=1
    fi
    echo "Usage: $0 [OPTION]... PATTERN [[REPLACEMENT] [FILE]...]"
    echo
    echo Replace regex patterns in filenames
    echo
    echo "Rename specified files (or files in the current directory) by replacing"
    echo "PATTERN with (possibly empty) REPLACEMENT."
    echo
    echo "  -i, --interactive     Prompt before overwrite, default = $interactive"
    echo "  -f, --force           Do not prompt before overwriting, default = $force"
    echo
    echo "  -g, --global          Replace all occurences of pattern, default = $global"
    echo
    echo "  -t, --test            Test only, do not rename, default = $testonly"
    echo
    echo "  -h, --help            Print this help"
    echo
    exit $exitcode
}

args=
interactive=on
force=off
testonly=off
global=off
pattern=
replacement=
replacement_flag=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    -f|--force) force=on ;;
    -t|--test) testonly=on ;;
    -g|--global) global=on ;;
    --) shift
        while [ $# != 0 ]; do 
            if test "$pattern"; then
                if test $replacement_flag = off; then
                    replacement_flag=on
                    replacement=$1
                else
                    args="$args \"$1\""
                fi
            else
                pattern=$1
            fi
            shift
        done
        break
        ;;
    -?*) usage "Unknown option: $1" ;;
    *) 
        if test "$pattern"; then
            if test $replacement_flag = off; then
                replacement_flag=on
                replacement=$1
            else
                args="$args \"$1\""
            fi
        else
            pattern=$1
        fi
        ;;
    esac
    shift
done

test "$pattern" || usage "Error: specify pattern"

test "$args" && eval "set -- $args" || set -- *

cp_ops=
test $force = on && cp_ops="$cp_ops -f"
test $interactive = on && cp_ops="$cp_ops -i"

test $global = on && s_flags=g || s_flags=

test $testonly = off && msg= || msg='test: '

for from; do
    to=$(echo $from | sed -e "s/$pattern/$replacement/$s_flags")
    if test "$from" != "$to"; then
        echo $msg "\`$from' -> \`$to'"
        test $testonly = off && cp $cp_ops -- "$from" "$to"
    fi
done
