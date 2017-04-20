#!/usr/bin/awk -f
#
# Compute the variance of numeric values on stdin
#

/^-?[0-9.]/ {
    sum += $0
    sqsum += $0 * $0
    ++nr
}

END { 
    if (nr > 0) {
        avg = sum / nr
        print sqsum / nr - avg * avg
    }
}
