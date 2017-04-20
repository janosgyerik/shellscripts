#!/usr/bin/awk -f
#
# Print the selected column on stdin
#

BEGIN {
    col = 0
    for (i = 1; i < ARGC; i++) {
        col = ARGV[i]
        delete ARGV[i]
    }
}

{
    print $col
}
