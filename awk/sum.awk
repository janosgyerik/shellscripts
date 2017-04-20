#!/usr/bin/awk -f
#
# Compute the sum of numeric values on stdin
#

/^-?[0-9.]/ {
    sum += $0
}

END {
    print sum
}
