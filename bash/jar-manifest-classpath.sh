#!/bin/bash

workdir=$TMPDIR/$(basename "$0")-work-$$

cleanup() {
    rm -fr "$workdir"
}

mkdir -p "$workdir"
trap 'cleanup' 1 2 3 15 

for jar; do
    if ! test -f $jar; then
        echo warning: not a file: $jar
        continue
    fi
    [[ $jar = /* ]] || jar=$PWD/$jar
    (
        cd "$workdir" || exit 1
        jar xf "$jar"
        sed -ne '/^Class-Path:/,$p' META-INF/MANIFEST.MF | sed -e 's/^Class-Path: //' -e 's/^ //' | tr -d '\n' | tr ' ' '\n'
    )
done

cleanup
