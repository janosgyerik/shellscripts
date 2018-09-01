#!/usr/bin/env bash
#
# Convert PDF files to MOBI format easily using the ebook-convert utility of Calibre
#

set -euo pipefail

format=mobi

converter=ebook-convert
type "$converter" &>/dev/null || {
    echo "This script requires the program $converter. Make sure it's on your PATH."
    exit 1
}

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$@"
        exitcode=1
    fi
    echo "Usage: $0 [OPTION]... [PDF file]..."
    echo
    echo "Convert PDF files to $format format easily using the ebook-convert utility of Calibre"
    echo
    echo Options:
    echo
    echo "  -h, --help         Print this help"
    echo
    exit $exitcode
}

args=()
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) args+=("$1") ;;
    esac
    shift
done

set -- "${args[@]}"

test $# != 0 || usage "Error: specify PDF files to convert"

for path; do
    out=$path.$format

    if [[ -f $out ]]; then
        echo "* output file exist, skipping ..."
        continue
    fi

    "$converter" "$path" "$out"
done
