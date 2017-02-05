#!/usr/bin/env bash
#
# SCRIPT: template-sh.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-08-11
# REV:    1.0.T (Valid are A, B, D, T and P)
#
# PLATFORM: Not platform dependent (Confirmed in: Linux, FreeBSD, Solaris 10)
#
# PURPOSE: Generate a /bin/sh script template with a simple command line parser
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          

usage() {
    test $# = 0 || echo "$@"
    echo "Usage: $0 [OPTION]... FILENAME"
    echo
    echo Generate a /bin/sh script template with a simple argument parser
    echo
    echo Options:
    echo "  -a, --author AUTHOR     Name of the author, default = $author"
    echo "  -d, --description DESC  Description of the script, default = $description"
    echo "  -f, --flag FLAG         A parameter that takes no arguments"
    echo "  -p, --param PARAM       A parameter that takes one argument"
    echo
    echo "  -h, --help              Print this help"
    echo
    exit 1
}

set_longest() {
    len=${#1}
    test $len -gt $longest && longest=$len
}

set_padding() {
    len=${#1}
    padding=$(printf %$((width - len))s '')
}

test "$AUTHOR" && author=$AUTHOR || author="$(id -un) <$(id -un)@$(hostname)>"
longest=5
description='BRIEF DESCRIPTION OF THE SCRIPT'
# options starting with "f" are flags, "p" are parameters.
options=
file=
flags=
params=
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
    -a|--author) shift; author=$1 ;;
    -d|--description) shift; description="$1" ;;
    -f|--flag) shift; options="$options f$1"; set_longest $1; flags=1 ;;
    -p|--param) shift; options="$options p$1"; set_longest $1; params=1 ;;
#    --) shift; while test $# != 0; do args="$args \"$1\""; shift; done; break ;;
    -|-?*) usage "Unknown option: $1" ;;
#    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
    *) test "$file" && usage || file=$1 ;;
    esac
    shift
done

test "$file" || usage

#  -p, --param PARAM  A parameter that takes no arguments
#^^^^^^^8^^^^L^^^^^L^^
width=$((8 + longest + 2 + longest))
test $width -gt 40 && width=40

if test "$file" != "-"; then
    [[ "$file" == *.sh ]] || file="$file".sh
else
    file=/tmp/.template-sh.$$
    test=1
fi
echo "Creating \"$file\" ..."

trap 'rm -f "$file"; exit 1' 1 2 3 15

cat << EOF > "$file"
#!/bin/sh
#
# SCRIPT: $(basename "$file")
# AUTHOR: $author
# DATE:   $(date +%F)
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
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

set -e

usage() {
    test \$# = 0 || echo "\$@"
    echo "Usage: \$0 [OPTION]... [ARG]..."
    echo
    echo $description
    echo
    echo Options:
EOF

for i in $options; do 
    f=${i:0:1}
    name=${i:1}
    vname=${name//-/_}
    oname=${name//_/-}
    first=${name:0:1}

    if test $f = f; then
        # this is a flag
        optionstring="  -$first, --$oname"
        echo Adding flag: $optionstring
        set_padding "$optionstring"
        echo "    echo \"$optionstring$padding default = \$$vname\"" >> "$file"
        optionstring="      --no-$oname"
        echo Adding flag: $optionstring
        set_padding "$optionstring"
        echo "    echo \"$optionstring$padding default = ! \$$vname\"" >> "$file"
    else
        # this is a param
        pname=$(echo $oname | tr a-z- A-Z_)
        optionstring="  -$first, --$oname $pname"
        echo Adding param: $optionstring
        set_padding "$optionstring"
        echo "    echo \"$optionstring$padding default = \$$vname\"" >> "$file"
    fi
done

helpstring="  -h, --help"
set_padding "$helpstring"
cat << EOF >> "$file"
    echo
    echo "$helpstring$padding Print this help"
    echo
    exit 1
}

args=
EOF

test "$flags" || echo '#flag=off' >> "$file"
test "$params" || echo '#param=' >> "$file"

for i in $options; do 
    f=${i:0:1}
    name=${i:1}
    vname=${name//-/_}
    oname=${name//_/-}
    test $f = f && echo "$vname=off" >> "$file" || echo "$vname=" >> "$file"
done

cat << EOF >> "$file"
while test \$# != 0; do
    case \$1 in
    -h|--help) usage ;;
EOF

if ! test "$flags"; then
    # an example entry to illustrate parsing a flag
    echo "#    -f|--flag) flag=on ;;" >> "$file"
    echo "#    --no-flag) flag=off ;;" >> "$file"
fi
if ! test "$params"; then
    # an example entry to illustrate parsing a param
    echo "#    -p|--param) shift; param=\$1 ;;" >> "$file"
fi

for i in $options; do 
    f=${i:0:1}
    name=${i:1}
    vname=${name//-/_}
    oname=${name//_/-}
    first=${name:0:1}
    if test $f = f; then
        # this is a flag
        echo "    -$first|--$oname) $vname=on ;;" >> "$file"
        echo "    --no-$oname) $vname=off ;;" >> "$file"
    else
        # this is a param
        echo "    -$first|--$oname) shift; $vname=\$1 ;;" >> "$file"
    fi
done

cat << "EOF" >> "$file"
#    --) shift; while test $# != 0; do args="$args \"$1\""; shift; done; break ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

test $# -gt 0 || usage
EOF

chmod +x "$file"
test "$test" && cat "$file"
