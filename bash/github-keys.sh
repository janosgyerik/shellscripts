#!/usr/bin/env bash
#
# SCRIPT: github-keys.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2019-09-24
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Fetch public keys of specified GitHub users from https://github.com/user.keys
#

set -euo pipefail

usage() {
    local exitcode=0
    if [[ $# != 0 ]]; then
        echo "$*" >&2
        exitcode=1
    fi
    cat << EOF
Usage: $0 [OPTION]... [USERNAME]...

Fetch public keys of specified GitHub users from https://github.com/user.keys

Options:

  -h, --help         Print this help

EOF
    exit "$exitcode"
}

args=()
while [[ $# != 0 ]]; do
    case $1 in
    -h|--help) usage ;;
    --) shift; while [[ $# != 0 ]]; do args+=("$1"); shift; done; break ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) args+=("$1") ;;
    esac
    shift
done

set -- "${args[@]}"

[[ $# != 0 ]] || usage

for username; do
    curl -s "https://github.com/$username.keys" | sed -e "s/\$/ $username@github/"
done
