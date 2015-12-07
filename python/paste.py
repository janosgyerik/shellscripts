#!/usr/bin/env python

import os
import argparse

parser = argparse.ArgumentParser(description='merge corresponding or subsequent lines of files')
parser.add_argument('files', nargs='+')
parser.add_argument('-s', dest='sep', default=',', help='separator')

args = parser.parse_args()

streams = []
for path in args.files:
    if os.path.isfile(path):
        streams.append(open(path))

while True:
    cols = []
    reached_eof = 0
    for stream in streams:
        line = stream.readline()
        if not line:
            reached_eof += 1
        cols.append(line.strip())
    print(args.sep.join(cols))
    if reached_eof == len(streams):
        break

for stream in streams:
    stream.close()
