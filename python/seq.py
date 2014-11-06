#!/usr/bin/env python

import argparse


parser = argparse.ArgumentParser(description='Print sequences of numbers')
parser.add_argument('first', nargs='?', default=1, type=int)
parser.add_argument('incr', nargs='?', default=1)
parser.add_argument('last', type=int)

args = parser.parse_args()

for num in range(args.first, args.last + 1):
    print(str(num))

