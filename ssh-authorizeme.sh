#!/bin/sh

test "$1" || exit 1
remote=$1

test "$2" && file=$2 || file=
tmpfile=/tmp/.ssh-authorizeme.sh-$$

if ! test -f "$file"; then
    trap 'rm -f $tmpfile; exit 1' 1 2 3 15
    if ssh-add -L >/dev/null 2>/dev/null; then
	file=$(ssh-add -L | awk '{print $NF}').pub
    elif test -f ~/.ssh/id_rsa.pub; then
	file=~/.ssh/id_rsa.pub
    else
	file=
    fi
fi

test -f "$file" && ssh $remote 'mkdir -p .ssh; cat >> .ssh/authorized_keys; chmod -R go-rwx .ssh' < $file

rm -f $tmpfile

# eof
