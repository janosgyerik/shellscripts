#!/bin/sh
#
# SCRIPT: template-sh.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
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
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... FILENAME"
    echo
    echo "Generate a /bin/sh script template with a simple command line parser."
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
    l=$(echo $1 | wc -c)
    test $l -gt $longest && longest=$l
}

#flag=off
#param=
#args=
test "$AUTHOR" && author=$AUTHOR || author="$(id -un) <$(id -un)@$(hostname)>"
longest=5
description='BRIEF DESCRIPTION OF THE SCRIPT'
# options starting with "f" are flags, options starting with "p" are parameters.
options=
file=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    --no-flag) flag=off ;;
#    -p|--param) shift; param=$1 ;;
    -a|--author) shift; author=$1 ;;
    -d|--description) shift; description="$1" ;;
    -f|--flag) shift; options="$options f$1"; set_longest $1 ;;
    -p|--param) shift; options="$options p$1"; set_longest $1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
#    -) usage "Unknown option: $1" ;;
    -?*) usage "Unknown option: $1" ;;
#    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
    *) file=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

test "$file" || usage

width=$(expr 8 + $longest + 1 + $longest - 2)

if [ "$file" != "-" ]; then 
    test $(expr "$file" : '.*\.sh$') = 0 && file="$file.sh"
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
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

usage() {
    test \$# = 0 || echo \$@
    echo "Usage: \$0 [OPTION]... [ARG]..."
    echo
    echo $description
    echo
    echo Options:
EOF

set_padding() {
    padding=
    j=$(echo "$1" | wc -c)
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
	set_padding "$optionstring"
	echo "    echo \"$optionstring$padding default = \$$name\"" >> "$file"
	optionstring="      --no-$name"
	echo "Adding flag --no-$name ..."
	set_padding "$optionstring"
	echo "    echo \"$optionstring$padding default = ! \$$name\"" >> "$file"
    else
	# this is a param
	pname=$(echo $name | tr a-z A-Z)
	optionstring="  -$first, --$name $pname"
	echo "Adding param -$first, --$name ..."
	set_padding "$optionstring"
	echo "    echo \"$optionstring$padding default = \$$name\"" >> "$file"
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
EOF

# an example entry to illustrate parsing a flag
echo "#    -f|--flag) flag=on ;;" >> "$file"
echo "#    --no-flag) flag=off ;;" >> "$file"
# an example entry to illustrate parsing a param
echo "#    -p|--param) shift; param=\$1 ;;" >> "$file"

for i in $options; do 
    f=$(expr $i : '\(.\)')
    name=$(expr $i : '.\(.*\)')
    first=$(expr $name : '\(.\)')
    if [ $f = f ]; then
	# this is a flag
	echo "    -$first|--$name) $name=on ;;" >> "$file"
	echo "    --no-$name) $name=off ;;" >> "$file"
    else
	# this is a param
	echo "    -$first|--$name) shift; $name=\$1 ;;" >> "$file"
    fi
done

cat << "EOF" >> "$file"
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -) usage "Unknown option: $1" ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

test $# -gt 0 || usage

# eof
EOF

chmod +x "$file"
test "$test" && cat "$file"

# eof
