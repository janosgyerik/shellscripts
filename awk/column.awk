#!/usr/bin/awk -f
#
# Columnate lists, imitating the BSD `column -t` command
#

{
    lines[NR] = $0;
    for (i = 1; i <= NF; i++) {
        if (length($i) > widths[i]) widths[i] = length($i);
    }
}

END {
    for (i = 1; i <= NR; i++) {
        $0 = lines[i];
        for (j = 1; j < NF; j++) {
            printf sprintf("%-" (widths[j] + 2) "s", $j);
        }
        print $j;
    }
}
