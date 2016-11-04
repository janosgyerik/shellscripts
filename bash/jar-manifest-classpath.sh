#!/bin/bash

case "$1" in
    -h|--help)
        echo Usage: $0 JAR...
        echo
        echo Print the classpath entries of the manifest of JAR files
        exit 1
        ;;
esac

if test -d "$TMPDIR"; then
    :
elif test -d "$TMP"; then
    TMPDIR=$TMP
elif test -d /var/tmp; then
    TMPDIR=/var/tmp
else
    TMPDIR=/tmp
fi
workdir=$TMPDIR/$(basename "$0")-work-$$

cleanup() {
    rm -fr "$workdir"
}

mkdir -p "$workdir"
trap 'cleanup' 1 2 3 15 

manifest_relpath=META-INF/MANIFEST.MF

for jar; do
    if ! test -f $jar; then
        echo warning: not a file: $jar
        continue
    fi
    [[ $jar = /* ]] || jar=$PWD/$jar
    (
        cd "$workdir" || exit 1
        jar xf "$jar" $manifest_relpath
        sed -ne '/^Class-Path:/,/^[^ ]/p' $manifest_relpath | sed -e 's/^Class-Path: //' -e '$s/^[^ ].*//' -e 's/^ //' | tr -d '\r\n' | tr ' ' '\n'
    )
done

cleanup
