#!/usr/bin/env bash
#
# SCRIPT: mv-many.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2019-07-27
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Rename files and directories by editing their names in $VISUAL or $EDITOR
#

set -euo pipefail

usage() {
    local exitcode=0
    if [[ $# != 0 ]]; then
        echo "$*" >&2
        exitcode=1
    fi

    cat << EOF
Usage: $0 [OPTION]... [FILES]

Rename files and directories by editing their names in $editor

Specify the paths to rename, or else * will be used by default.
Limitations: the paths must not contain newline characters.
EOF

    if [[ $editor == *vim ]]; then
        echo "Tip: to abort editing in $editor, exit with :cq command."
    fi

    cat << "EOF"

Options:
  -h, --help         Print this help

EOF
    exit "$exitcode"
}

fatal() {
    echo "Error: $*" >&2
    exit 1
}

find_editor() {
    # Following READLINE conventions, try VISUAL first and then EDITOR

    if [[ ${VISUAL+x} ]]; then
        echo "$VISUAL"
        return
    fi

    # shellcheck disable=SC2153
    if [[ ${EDITOR+x} ]]; then
        echo "$EDITOR"
        return
    fi

    fatal 'could not determine editor to use, please set VISUAL or EDITOR; aborting.'
}

editor=$(find_editor)

oldnames=()
while [[ $# != 0 ]]; do
    case $1 in
    -h|--help) usage ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) oldnames+=("$1") ;;
    esac
    shift
done

work=$(mktemp)
trap 'rm -f "$work"' EXIT

if [[ ${#oldnames[@]} == 0 ]]; then
    oldnames=(*)
fi

printf '%s\n' "${oldnames[@]}" > "$work"
"$editor" "$work" || fatal "vim exited with error; aborting without renaming."
mapfile -t newnames < "$work"

[[ "${#oldnames[@]}" == "${#newnames[@]}" ]] ||
    fatal "expected ${#oldnames[@]} lines in the file, got ${#newnames[@]}; aborting without renaming."

for ((i = 0; i < ${#oldnames[@]}; i++)); do
    old=${oldnames[i]}
    new=${newnames[i]}
    if [[ "$old" != "$new" ]]; then
        mv -vi "$old" "$new"
    fi
done
