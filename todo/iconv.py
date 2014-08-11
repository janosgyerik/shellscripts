#!/usr/bin/env python

import os
import sys
import glob

def iconv(fromfile, tofile, fromcode, tocode):
    try:
	f = open(fromfile, 'r').read()
    except Exception, e:
	print e
	sys.exit(1)

    try:
    	data = f.decode(fromcode)
    except Exception, e:
	print e
	sys.exit(1)

    f = open(tofile, 'w')
    try:
	f.write(data.encode(tocode))
    except Exception, e:
	print e
    finally:
	f.close()

if __name__ == '__main__':
    from optparse import OptionParser
    parser = OptionParser()
    parser.add_option('-f', '--from', dest = 'from_', metavar = 'FROM', help = 'encoding of original text')
    parser.add_option('-t', '--to', help = 'encoding for output')
    parser.add_option('-o', '--out', help = 'output file')
    (options, args) = parser.parse_args()

    if options.from_ is None:
	print 'Error: specify original encoding with -f or --from'
	parser.print_help()
	sys.exit(1)

    if options.to is None:
	print 'Error: specify output encoding with -t or --to'
	parser.print_help()
	sys.exit(1)

    files = []

    for f in args:
	if os.path.exists(f):
	    files.append(f)
	else:
	    tmplist = glob.glob(f)
	    if len(tmplist) > 0:
		files.extend(tmplist)
	    else:
		print 'Warning: file or pattern "%s" does not exist' % f

    for f in files:
	if options.out is None:
	    print '* converting file %s: %s -> %s ' % (f, options.from_, options.to)
	    iconv(f, f, options.from_, options.to)
	else:
	    print '* converting file %s -> %s: %s -> %s ' % (f, options.out, options.from_, options.to)
	    iconv(f, options.out, options.from_, options.to)

