#!/usr/bin/env bash
#
# SCRIPT: concat-movies.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2017-02-05
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Concatenate movies
#

set -e

usage() {
    test $# = 0 || echo "$@"
    echo "Usage: $0 [OPTION]... movie1 movie2 [movie3]..."
    echo
    echo Concatenate movies
    echo
    echo Options:
    echo "  -t, --target             default = $target"
    echo
    echo "  -z, --zenity             default = $zenity"
    echo "  -p, --progress           default = $progress"
    echo
    echo "  -h, --help               Print this help"
    echo
    exit 1
}

args=()
target=
zenity=off
progress=off
testrun=off
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
    -t|--target) shift; target=$1 ;;
    -z|--zenity) zenity=on ;;
    -p|--progress) progress=on ;;
    --testrun) testrun=on ;;
    --) shift; while test $# != 0; do args+=("$1"); shift; done; break ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) args+=("$1") ;;
    esac
    shift
done

set -- "${args[@]}"  # save arguments in $@. Use "$@" in for loops, not $@ 

percent() {
    local num=$1
    local target=$2
    echo $((100 * num / target))
}

size() {
    wc -c < "$1"
}

write_test_file() {
    # used only for testing the script
    path=$1
    size=$2

    > "$path"
    ((step = size / 10))
    for ((i = 0; i < 10; i++)); do
        dd if=/dev/random count=1 bs=$step >> "$path" 2>/dev/null
        sleep 1
    done
}

testrun() {
    # used only for testing the script
    target=$(mktemp)
    size=123
    (
    write_test_file "$target" $size &
    pid=$!
    while ps -p $pid >/dev/null; do
        if test -f "$target"; then
            current_size=$(size "$target")
        else
            current_size=0
        fi
        percent $current_size $size
        sleep 1
    done
    wait $pid
    ) |
    zenity --progress --title='Concatenate movies' --text='In progress...' --percentage 0
    if [ $? = -1 ]; then
        zenity --error --text='Concatenation canceled.'
    fi
}

make_sorted() {
    sorted=("$@")
    for ((i = 1; i < $#; )); do
        prev=${sorted[i - 1]}
        current=${sorted[i]}
        if [[ $prev == $current ]] || [[ $prev < $current ]]; then
            ((i++))
        else
            sorted[i - 1]=$current
            sorted[i]=$prev
            ((i > 1)) && ((i--))
        fi
    done
}

set_target() {
    target=$1; shift

    if test ! "$target"; then
        for target; do
            ext=${target##*.}
            test "$ext" = "$target" && ext=
            test "$ext" || ext=movie

            target=${target%.*}
            target=${target%[0-9]*}
            target=${target%[cC][dD]}
            target=$(echo $target)
            test "$target" || target=movie

            break
        done
        target=$target.$ext
    fi
}

concat() {
    target=$1; shift
    input=
    for f; do input=$input"|$f"; done
    ffmpeg -i "concat:${input:1}" -c copy "$target" -loglevel quiet
}

sum_size() {
    total=0
    for file; do
        size=$(size "$file")
        ((total += size))
    done
    echo $total
}

concat_with_zenity() {
    target=$1; shift
    size=$(sum_size "${sorted[@]}")
    (
    concat "$target" "${sorted[@]}" &
    pid=$!
    while ps -p $pid >/dev/null; do
        if test -f "$target"; then
            current_size=$(size "$target")
        else
            current_size=0
        fi
        percent $current_size $size
        sleep 1
    done
    wait $pid
    ) |
    zenity --progress --title='Concatenate movies' --text='In progress...' --percentage 0
    if [ $? = -1 ]; then
        zenity --error --text='Concatenation canceled.'
    fi
}

concat_with_progress() {
    target=$1; shift
    size=$(sum_size "${sorted[@]}")
    concat "$target" "${sorted[@]}" &
    pid=$!
    while ps -p $pid >/dev/null; do
        if test -f "$target"; then
            current_size=$(size "$target")
        else
            current_size=0
        fi
        percent=$(percent $current_size $size)
        echo Concatenation in progress: $percent%
        sleep 1
    done
    wait $pid
}

concat_runner() {
    target=$1; shift
    make_sorted "$@"
    set_target "$target" "$@"

    if test $zenity = on; then
        concat_with_zenity "$target" "${sorted[@]}"
    elif test $progress = on; then
        concat_with_progress "$target" "${sorted[@]}"
    else
        concat "$target" "${sorted[@]}"
    fi
}

if test $testrun = on; then
    testrun
    exit
fi

test $# -gt 0 || usage

[[ $# < 2 ]] && usage "Fatal: need at least 2 movie files to concatenate"

concat_runner "$target" "$@"
