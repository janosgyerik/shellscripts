#!/usr/bin/env python

from datetime import datetime
import argparse


def main():
    parser = argparse.ArgumentParser(description='Print the current date but with specified values overridden')
    parser.add_argument('-m', '--month', type=int)
    parser.add_argument('-d', '--day', type=int)
    parser.add_argument('--hour', type=int)

    args = parser.parse_args()

    date = datetime.now()

    if args.month:
        date = date.replace(month=args.month)
    if args.day:
        date = date.replace(day=args.day)
    if args.hour:
        date = date.replace(hour=args.hour)

    print(date.strftime('%a %b %e %T %Y'))

if __name__ == '__main__':
    main()
