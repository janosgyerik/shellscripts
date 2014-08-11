#!/usr/bin/env python

import os
import xml.dom.minidom

if __name__ == '__main__':
    from optparse import OptionParser
    usage = 'usage: %prog [options] file...'
    parser = OptionParser(usage = usage)
    (options, args) = parser.parse_args()

    if len(args) < 1:
	parser.print_help();

    for path in args:
	if not os.path.exists(path):
	    print "Path does not exist, skipping: " + path
	    continue
	if not os.path.isfile(path):
	    print "Path is not a file, skipping: " + path
	    continue
	
	print xml.dom.minidom.parse(path).toprettyxml()


# eof
