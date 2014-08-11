#! /usr/bin/env python

import optparse
import os
import re

startsWithDigits = re.compile('^[0-9]')

def getlast_num_time(filename):
    f = open(filename)
    line = f.readline()
    lastnum = 0
    lasttime = 0

    while line:
	if startsWithDigits.match(line):
	    lastnum = line
	    line = f.readline()
	    lasttime = line.split(' ')[2]
	    line = f.readline()
	    while line.strip() != '':
		line = f.readline()
	line = f.readline()

    return (int(lastnum.strip()), lasttime.strip())

def add_times(timestr1, timestr2):
    (h1, m1, s1) = timestr1.split(':')
    (h2, m2, s2) = timestr2.split(':')
    h1 = int(h1)
    h2 = int(h2)
    m1 = int(m1)
    m2 = int(m2)

    s1 = float(s1.replace(',', '.'))
    s2 = float(s2.replace(',', '.'))
    ss = s1 + s2
    if ss >= 60: 
	m2 += int(ss / 60)
	ss = ss % 60
    ss = str(ss).replace('.', ',')

    mm = m1 + m2
    if mm >= 60:
	h2 += int(mm / 60)
	mm = mm % 60

    hh = h1 + h2

    return ('%02s:%02s:%s' % (hh, mm, ss)).replace(' ', '0')

def add_num_time(filename, lastnum, lasttime):
    f = open(filename)
    line = f.readline().strip()

    while line:
	if startsWithDigits.match(line):
	    num = int(line)
	    print lastnum + num

	    line = f.readline().strip()
	    tt = line.split(' ')
	    print add_times(lasttime, tt[0]),
	    print '-->',
	    print add_times(lasttime, tt[2])

	    line = f.readline().strip()
	    print line
	    while line != '':
		line = f.readline().strip()
		print line
	else:
	    print line

	line = f.readline().strip()

if __name__ == '__main__':
    parser = optparse.OptionParser()
    parser.set_usage('%prog [options] srt1 srt2')
    parser.add_option('--gap', help='time gap between the subtitle files')

    (options, args) = parser.parse_args()

    if len(args) < 2: 
	parser.error('You need to specify two srt files.')

    for f in args:
	if not os.path.isfile(f):
	    parser.error('Not a file: %s' % f)

    (lastnum, lasttime) = getlast_num_time(args[0])

    f = open(args[0])
    line = f.readline()
    print line,

    while line:
	print line,
	line = f.readline()

    add_num_time(args[1], lastnum, lasttime)




# eof
