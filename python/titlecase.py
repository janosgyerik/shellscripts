#!/usr/bin/env python

import os
import re
import argparse

re_junk = re.compile(r'[._-]')
re_spaces = re.compile(r'\s\s+')


def print_rename(old_filename, new_filename):
    print('{} -> {}'.format(old_filename, new_filename))


def do_rename(old_path, new_path):
    print_rename(old_path, new_path)
    os.rename(old_path, new_path)


def get_new_path(old_path):
    dirpart, filepart = os.path.split(old_path)
    if filepart.startswith('.'):
        return old_path
    base, ext = os.path.splitext(filepart)
    base = re_junk.sub(' ', base)
    base = re_spaces.sub(' ', base).strip()
    if not base:
        return old_path
    return os.path.join(dirpart, base.title() + ext)


def titlecase(old_path, fun):
    if not os.path.exists(old_path):
        return

    new_path = get_new_path(old_path)
    if old_path == new_path:
        return

    fun(old_path, new_path)


def main():
    parser = argparse.ArgumentParser(description='Rename files to "titlecased" and "sanitized".')
    parser.add_argument('-n', '--dry-run', action='store_true', help='Print what would happen don\'t rename')
    parser.add_argument('paths', nargs='+')

    args = parser.parse_args()
    fun = print_rename if args.dry_run else do_rename

    for path in args.paths:
        titlecase(path, fun)


if __name__ == '__main__':
    main()
