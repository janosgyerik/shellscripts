#!/usr/bin/env bash
#
# SCRIPT: mv-replace.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2004-11-28
#
# PLATFORM: Not platform dependent (Confirmed in: Ubuntu)
#
# PURPOSE: Rename specified files (or files in the current directory) by
#          replacing <pattern> with (possibly empty) <replacement>.
#
#

usage() {
    test $# = 0 || echo $@
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
    exit 1
}

args=
#arg=
#flag=off
#param=
interactive=on
force=off
testonly=off
global=off
pattern=
replacement=
replacement_flag=off
renum=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
    -f|--force) force=on ;;
    -t|--test) testonly=on ;;
    -g|--global) global=on ;;
    --renum) renum=on ;;
#    -p|--param) shift; param=$1 ;;
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
    if test $renum = on; then
        args="$args \"$1\""
    elif test "$pattern"; then
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

test "$pattern" -o $renum = on || usage

test "$args" && eval "set -- $args" || set -- *

mv_ops=
test $force = on && mv_ops="$mv_ops -f"
test $interactive = on && mv_ops="$mv_ops -i"

test $global = on && s_flags=g || s_flags=

test $testonly = off && msg= || msg='test: '

i=0
for from; do
    if test $renum = off; then
        to=$(echo $from | sed -e "s/$pattern/$replacement/$s_flags")
    else
        ((i++))
        to=$(printf "%02d-%s" $i "$from")
    fi
    if test "$from" != "$to"; then
        echo $msg "\`$from' -> \`$to'"
        test $testonly = off && mv $mv_ops -- "$from" "$to"
    fi
done
