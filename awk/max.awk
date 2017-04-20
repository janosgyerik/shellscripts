#!/usr/bin/awk -f
#
# Compute the minimum of numeric values on stdin
#

BEGIN {
    first = 1
}

$1 ~ /^-?[0-9.]/ { 
    if (first) {
        first = 0
        max = $1
    } else if ($1 > max) {
        max = $1
    }
}

END {
    print max
}
