#!/usr/bin/env bash
#
# SCRIPT: pwgen.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2019-07-31
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Generate random alphanumeric passwords
#

set -euo pipefail

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$*" >&2
        exitcode=1
    fi
    cat << EOF
Usage: $0 [OPTION]... [length [count]]

Generate random alphanumeric passwords

Options:

  -h, --help         Print this help
 
EOF
    exit "$exitcode"
}

args=()
while [[ $# != 0 ]]; do
    case $1 in
    -h|--help) usage ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) args+=("$1") ;;
    esac
    shift
done

set -- "${args[@]}"

case $# in
    0)
        length=8
        count=1
        ;;
    1)
        length=$1
        count=1
        ;;
    2)
        length=$1
        count=$2
        ;;
    *) usage
esac

alphabet=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
alphabet_length=${#alphabet}

pwgen() {
    local length=$1
    local i index pw=

    for ((i = 0; i < length; i++)); do
        index=$((RANDOM % alphabet_length))
        letter=${alphabet:index:1}
        pw+=$letter
    done

    echo "$pw"
}

pwgen_n() {
    local length=$1
    local count=$2
    local i

    for ((i = 0; i < count; i++)); do
        pwgen "$length"
    done
}

pwgen_n "$length" "$count"
