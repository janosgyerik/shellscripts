#!/usr/bin/env python

import os
import re

delimiter = ','

def quotrepl(matchobj):
    return re.sub(',', '_', matchobj.group(1))

if __name__ == '__main__':
    from optparse import OptionParser
    usage = 'usage: %prog [options] file'
    parser = OptionParser(usage = usage)
    parser.add_option("-d", help="Set delimiter", dest="delimiter", default=delimiter)
    (options, args) = parser.parse_args()
    delimiter = options.delimiter

    for path in args:
	if not os.path.exists(path):
	    print "Path does not exist, skipping: " + path
	    continue
	if not os.path.isfile(path):
	    print "Path is not a file, skipping: " + path
	    continue

	f = open(path)
	line = f.readline()

	mm = {}
	mmv = {}
	cols = re.split(delimiter, line.rstrip("\r\n"))
	for col in cols:
	    mm[col] = 0
	    mmv[col] = '?'

	for line in f:
	    line = re.sub(r'"([^"]*)"', quotrepl, line)

	    for col, val in zip(cols, re.split(delimiter, line.rstrip("\r\n"))):
		if len(val) > mm[col]:
		    mm[col] = len(val)
		    mmv[col] = val

	for col in cols:
	    print "%s\t%s\t%s" % (col, mm[col], mmv[col])


# eof
