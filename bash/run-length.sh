#!/usr/bin/env bash
#
# SCRIPT: run-length.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2019-10-12
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Compute run length encoding from text, or the reverse
#          For example, the run length encoding of aaabbc is 3a2b1c
#

set -euo pipefail

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$*" >&2
        exitcode=1
    fi
    cat << EOF
Usage: $0 [OPTION]... TEXT

Compute run length encoding from text, or the reverse

Options:
  -d, -r, --reverse          default = $reverse

  -h, --help             Print this help

EOF
    exit "$exitcode"
}

args=()
reverse=off
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
    -r|--reverse) reverse=on ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) args+=("$1") ;;
    esac
    shift
done

set -- "${args[@]}"

[[ $# = 1 ]] || usage

text=$1

encode() {
    [[ $text ]]

    local i c count=1 encoded=
    local prev=${text:0:1}

    [[ $prev != [0-9] ]]

    for ((i = 1; i <= ${#text}; ++i)); do
        c=${text:i:1}
        [[ $c != [0-9] ]]
        if [[ $prev = $c ]]; then
            ((count++))
        else
            encoded+=$count$prev
            count=1
        fi
        prev=$c
    done
    echo "$encoded"
}

decode() {
    [[ $text ]]

    local i j c num= decoded=
    for ((i = 0; i < ${#text}; ++i)); do
        c=${text:i:1}
        if [[ $c == [0-9] ]]; then
            num+=$c
            continue
        fi

        for ((j = 0; j < num; ++j)); do
            decoded+=$c
        done
        num=
    done
    echo "$decoded"
}

if [[ $reverse = off ]]; then
    encode "$text"
else
    decode "$text"
fi
