#!/bin/sh
#
# SCRIPT: template-sh.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2005-08-11
# REV:    1.0.T (Valid are A, B, D, T and P)
#
# PLATFORM: Not platform dependent (Confirmed in: Linux, FreeBSD, Solaris 10)
#
# PURPOSE: Generate the skeleton of a shell script, with the capability to
#          process "flags" and "params". Here, "flag" means option without
#          arguments, and "param" means option with one argument.
#          Note: the program (intentionally) does not handle flags/params
#          with funny characters in them. You should make simple, easy to use
#          flags/params anyway.
#
# REV LIST:
#        DATE:	DATE_of_REVISION
#        BY:	AUTHOR_of_MODIFICATION   
#        MODIFICATION: Describe what was modified, new features, etc-
#
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... FILENAME"
    echo "Generate the template of a Bourne shell script that can parse simple parameters."
    echo
    echo "  -a, --author AUTHOR   Name of the author, default = $author"
    echo "  -f, --flag FLAG       A parameter that takes no arguments"
    echo "  -p, --param PARAM     A parameter that takes one argument"
    echo "      --stub            Add a 'stub' to the top of the script, default = $stub"
    echo
    echo "  -h, --help            Print this help"
    echo
    exit 1
}

set_longest() {
    l=$(echo $1 | wc -c)
    test $l -gt $longest && longest=$l
}

neg=0
#flag=off
#param=
#args=
test "$AUTHOR" && author=$AUTHOR || author='AUTHOR <email@address.com>'
stub=off
longest=5
# options starting with "f" are flags, options starting with "p" are parameters.
options=
file=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    !) neg=1; shift; continue ;;
#    -f|--flag) test $neg = 1 && flag=off || flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -a|--author) shift; author=$1 ;;
    --stub) test $neg = 1 && stub=off || stub=on ;;
    -f|--flag) shift; options="$options f$1"; set_longest $1 ;;
    -p|--param) shift; options="$options p$1"; set_longest $1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
#    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
    *) file=$1 ;;  # forgiving with excess arguments
    esac
    shift
    neg=0
done

test "$file" || usage

width=$(expr 8 + $longest + 1 + $longest - 2)

if [ "$file" != "-" ]; then 
    test $(expr "$file" : '.*\.sh$') = 0 && file="$file.sh"
else
    file=/tmp/.template-sh.$$
    test=1
fi
echo Creating \"$file\" ...

trap 'rm -f "$file"; exit 1' 1 2 3 15

echo '#!/bin/sh' > "$file"

if [ $stub = on ]; then
    cat << EOF >> "$file"
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
# PURPOSE: Give a clear, and if necessary, long, description of the
#          purpose of the shell script. This will also help you stay
#          focused on the task at hand.
#
# REV LIST:
#        DATE:	DATE_of_REVISION
#        BY:	AUTHOR_of_MODIFICATION   
#        MODIFICATION: Describe what was modified, new features, etc-
#
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#
EOF
fi

cat << "EOF" >> "$file"

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo "BRIEF DESCRIPTION OF THE SCRIPT"
    echo
EOF

set_padding() {
    padding=
    j=$(echo $1 | wc -c)
    while [ $j -lt $width ]; do
	padding="$padding "
	j=$(expr $j + 1)
    done
}

has_flags=no
for i in $options; do 
    f=$(expr $i : '\(.\)')
    name=$(expr $i : '.\(.*\)')
    first=$(expr $name : '\(.\)')

    if [ $f = f ]; then
	# this is a flag
	has_flags=yes
	optionstring="  -$first, --$name"
	echo "Adding flag -$first, --$name ..."
    else
	# this is a param
	pname=$(echo $name | tr a-z A-Z)
	optionstring="  -$first, --$name $pname"
	echo "Adding param -$first, --$name ..."
    fi
    set_padding "$optionstring"
    echo "    echo \"$optionstring$padding default = \$$name\"" >> "$file"
done

helpstring="  -h, --help"
set_padding "$helpstring"
cat << EOF >> "$file"
    echo
    echo "$helpstring$padding Print this help"
    echo
    exit 1
}

neg=0
args=
#arg=
#flag=off
#param=
EOF

for i in $options; do 
    f=$(expr $i : '\(.\)')
    name=$(expr $i : '.\(.*\)')
    test $f = f && echo "$name=off" >> "$file" || echo "$name=" >> "$file"
done

test $has_flags = yes && ttmp="" || ttmp="#"
cat << EOF >> "$file"
while [ \$# != 0 ]; do
    case \$1 in
    -h|--help) usage ;;
$ttmp    !) neg=1; shift; continue ;;
EOF

# an example entry to illustrate parsing a flag
echo "#    -f|--flag) test \$neg = 1 && flag=off || flag=on ;;" >> "$file"
# an example entry to illustrate parsing a param
echo "#    -p|--param) shift; param=\$1 ;;" >> "$file"

for i in $options; do 
    f=$(expr $i : '\(.\)')
    name=$(expr $i : '.\(.*\)')
    first=$(expr $name : '\(.\)')
    if [ $f = f ]; then
	# this is a flag
	echo "    -$first|--$name) test \$neg = 1 && $name=off || $name=on ;;" >> "$file"
    else
	# this is a param
	echo "    -$first|--$name) shift; $name=\$1 ;;" >> "$file"
    fi
done

cat << "EOF" >> "$file"
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
    neg=0
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

test $# = 0 && usage

# eof
EOF

chmod +x "$file"
test "$test" && cat "$file"

# eof
