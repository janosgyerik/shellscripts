#!/usr/bin/env python

import optparse
import datetime
import shutil
import os

t = datetime.date.today()
date = str(t.year) + str(t.month) + str(t.day)

if __name__ == '__main__':
    parser = optparse.OptionParser()
    parser.set_usage('usage: %prog [options] file1... dir')
    parser.add_option('-d', '--date', help='Date to use instead of TODAY', dest='date', default=date)

    (options, args) = parser.parse_args()
    date = options.date

    if len(args) < 2: 
	parser.print_usage()
	parser.exit()

    targetdir = args[-1]
    if not os.path.isdir(targetdir): 
	print '* creating directory: ' + targetdir
	os.mkdir(targetdir)

    for f in args[:-1]:
	targetfile = targetdir + '/' + date + '-' + os.path.basename(f)
	print '* moving %s to %s' % (f, targetfile)
	shutil.move(f, targetfile)

