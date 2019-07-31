#!/usr/bin/env bash
#
# SCRIPT: template-sh.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-08-11
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Generate a Bash script template with a simple command line parser
#

set -euo pipefail

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$*" >&2
        exitcode=1
    fi
    echo "Usage: $0 [OPTION]... FILENAME"
    echo
    echo Generate a Bash script template with a simple argument parser
    echo
    echo Options:
    echo "  -a, --author AUTHOR     Name of the author, default = $author"
    echo "  -d, --description DESC  Description of the script, default = $description"
    echo "  -f, --flag FLAG         A parameter that takes no arguments"
    echo "  -p, --param PARAM       A parameter that takes one argument"
    echo
    echo "  -h, --help              Print this help"
    echo
    exit "$exitcode"
}

set_longest() {
    len=${#1}
    ((len > longest)) && longest=$len || :
}

set_padding() {
    len=${#1}
    if ((len < width)); then
        padding=$(printf %$((width - len))s '')
    else
        padding=
    fi
}

# shellcheck disable=SC2153
if test "${AUTHOR+x}"; then
    author=$AUTHOR
else
    username=$(id -un)
    author="$username <$username@$(hostname)>"
fi

ppattern='^[a-zA-Z0-9][a-zA-Z0-9_-]*[a-zA-Z0-9]$'
is_valid_param() {
    [[ $1 =~ $ppattern ]]
}

longest=5
description='BRIEF DESCRIPTION OF THE SCRIPT'
# options starting with "f" are flags, "p" are parameters.
options=()
flags=
params=
file=
force=off
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
    -a|--author) shift; author=$1 ;;
    -d|--description) shift; description=$1 ;;
    -f|--flag)
        shift
        [[ $# != 0 ]] || usage 'Error: the -f, --flag option requires a parameter'
        is_valid_param "$1" || usage "Invalid parameter name: '$1'; parameter names should match the pattern: $ppattern"
        options+=("f$1")
        set_longest "$1"
        flags=1
        ;;
    -p|--param)
        shift
        [[ $# != 0 ]] || usage 'Error: the -p, --param option requires a parameter'
        is_valid_param "$1" || usage "Invalid parameter name: '$1'; parameter names should match the pattern: $ppattern"
        options+=("p$1")
        set_longest "$1"
        params=1
        ;;
    --force) force=on ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) test "$file" && usage "Excess argument: $1" || file=$1 ;;
    esac
    shift
done

#  -p, --param PARAM  A parameter that takes no arguments
#^^^^^^^^LLLLL^LLLLL^^
((width = 8 + longest + 1 + longest))
((width > 40)) && width=40 || :

test "$file" || usage "Error: specify filename"

[[ "$file" == *.sh ]] || file=$file.sh

if test -f "$file"; then
    test $force = off && usage "Error: file exists. Use --force to clobber it."
fi

truncate() {
    : > "$file"
}

append() {
    cat >> "$file"
}

echo "Creating '$file' ..."

trap 'rm -f "$file"; exit 1' 1 2 3 15

truncate

cat << SCRIPT_TOP | append
#!/usr/bin/env bash
#
# SCRIPT: $(basename "$file")
# AUTHOR: $author
# DATE:   $(date +%F)
#
# PLATFORM: Not platform dependent
# PLATFORM: Linux only
# PLATFORM: FreeBSD only
#
# PURPOSE: $description
#          Give a clear, and if necessary, long, description of the
#          purpose of the shell script. This will also help you stay
#          focused on the task at hand.
#

set -euo pipefail

usage() {
    local exitcode=0
    if [ \$# != 0 ]; then
        echo "\$*" >&2
        exitcode=1
    fi
    cat << EOF
Usage: \$0 [OPTION]... [ARG]...

$description

Options:
SCRIPT_TOP

for op in "${options[@]}"; do
    f=${op:0:1}
    name=${op:1}
    vname=${name//-/_}
    oname=${name//_/-}
    first=${name:0:1}

    if test "$f" = f; then
        optionstring="  -$first, --$oname"
        # shellcheck disable=SC2086
        echo Adding flag: $optionstring
        set_padding "$optionstring"
        echo "$optionstring $padding default = \$$vname" | append
        optionstring="      --no-$oname"
        # shellcheck disable=SC2086
        echo Adding flag: $optionstring
        set_padding "$optionstring"
        echo "$optionstring $padding default = ! \$$vname" | append
    else
        # shellcheck disable=SC2018,SC2019
        pname=$(tr a-z A-Z <<< "$oname")
        optionstring="  -$first, --$oname $pname"
        # shellcheck disable=SC2086
        echo Adding param: $optionstring
        set_padding "$optionstring"
        echo "$optionstring $padding default = \$$vname" | append
    fi
done

helpstring="  -h, --help"
set_padding "$helpstring"
cat << SCRIPT_MID | append

$helpstring $padding Print this help

EOF
    exit "\$exitcode"
}

args=()
SCRIPT_MID

test "$flags" || echo '#flag=off' | append
test "$params" || echo '#param=' | append

for op in "${options[@]}"; do
    f=${op:0:1}
    name=${op:1}
    vname=${name//-/_}
    oname=${name//_/-}
    test "$f" = f && echo "$vname=off" || echo "$vname="
done | append

cat << "EOF" | append
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
EOF

if ! test "$flags"; then
    # an example entry to illustrate parsing a flag
    echo "    #-f|--flag) flag=on ;;"
    echo "    #--no-flag) flag=off ;;"
fi | append

if ! test "$params"; then
    # an example entry to illustrate parsing a param
    echo "    #-p|--param) shift; param=\$1 ;;"
fi | append

for op in "${options[@]}"; do
    f=${op:0:1}
    name=${op:1}
    vname=${name//-/_}
    oname=${name//_/-}
    first=${name:0:1}
    if test "$f" = f; then
        echo "    -$first|--$oname) $vname=on ;;"
        echo "    --no-$oname) $vname=off ;;"
    else
        echo "    -$first|--$oname) shift; $vname=\$1 ;;"
    fi
done | append

cat << "EOF" | append
    #--) shift; while test $# != 0; do args+=("$1"); shift; done; break ;;
    -|-?*) usage "Unknown option: $1" ;;
    #*) args+=("$1") ;;  # script that takes multiple arguments
    esac
    shift
done

set -- "${args[@]}"  # save arguments in $@

test $# != 0 || usage "Error: specify ..."
EOF

chmod +x "$file"
