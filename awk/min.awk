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
        min = $1
    } else if ($1 < min) {
        min = $1
    }
}

END {
    print min
}
