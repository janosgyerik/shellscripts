#!/usr/bin/env python
#
# File: organizebydate.py
# Purpose: re-organize files with dates in their name to dated subdirectories.
#
import os
import re
import shutil

# Copy mode: copy files instead of move
copy = False

# Target directory to create tree structure. 
# If unset, it will be the same directory.
target = None

pattern_ym = re.compile('\d\d\d\d\d\d')

def treeByDate(path):
    if not os.path.exists(path):
	print "Path does not exist, skipping: " + path
	return
    if not os.path.isdir(path):
	print "Path is not a directory, skipping: " + path
	return

    if target == None:
	target_ = path
    else:
	target_ = target

    for f in os.listdir(path):
	if pattern_ym.match(f): 
	    continue

	m = pattern_ym.search(f)
	if m != None:
	    src = '%s%s%s' % (path, os.path.sep, f)
	    dstdir = '%s%s%s' % (target_, os.path.sep, m.group())
	    dst = '%s%s%s' % (dstdir, os.path.sep, f)
	    print '* Info: mv %s -> %s' % (src, dst)

	    if not os.path.isdir(dstdir):
		os.makedirs(dstdir)

	    if copy:
		shutil.copy2(src, dst)
	    else:
		if os.path.isfile(dst): os.remove(dst)
		os.rename(src, dst)
	else:
	    print '* Warn: file does not match pattern, ignoring: ' + f


if __name__ == '__main__':
    from optparse import OptionParser
    usage = 'usage: %prog [options] file'
    parser = OptionParser(usage = usage)
    parser.add_option("--copy", help="Set copy mode: copy files instead of move", dest="copy", default=copy, action="store_true")
    parser.add_option('-t', "--target", help="Set target root directory", dest="target", default=target)
    (options, args) = parser.parse_args()
    copy = options.copy
    target = options.target

    if len(args) > 0:
	for path in args:
	    treeByDate(path)
    else:
	treeByDate('.')

# eof
