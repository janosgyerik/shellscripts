#!/usr/bin/awk -f
# 
# Compute the average of numeric values on stdin
#

$1 ~ /^[0-9.]/ {
    sum += $1
    ++nr
}

END {
    if (nr) print sum / nr
}
