#!/usr/bin/env bash

if test "$@"; then
    echo Usage: $0
    echo
    echo Print the value of java.io.tmpdir
    exit 1
fi

java -XshowSettings 2>&1 | awk '/java.io.tmpdir *=/ { sub(/^[^=]+=[ \t]*/, ""); print; exit }'
