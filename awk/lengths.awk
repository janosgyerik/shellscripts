#!/usr/bin/awk -f
#
# Compute and print the lengths of lines on stdin
#

BEGIN {
    minlength = 0
    for (i = 1; i < ARGC; i++) {
        minlength = ARGV[i]
        delete ARGV[i]
    }
}

length($0) >= minlength {
    print length($0), $0
}
