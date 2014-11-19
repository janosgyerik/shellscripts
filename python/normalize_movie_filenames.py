#!/usr/bin/env python
'''
todo:
    fix files with date not in the right format
    --acr option to not rename specified acronyms
    support for subtitle files in the same dir before cleaning up
    work with single file args too not just dirs
    detect series = more than 3 movie files in a dir
    fetch date if missing
    detect duplicate files with date and no date
    detect multicd files that have been concatenated
    limit option for easier review
    skip option for easier review
'''

import os
import re
import argparse
import requests

nameformat_re_str = r'([A-Z0-9][\w,\-\']*)(( -)|( [A-Z0-9][\w,\-\']*))*( \{\d\d\d\d\})?( CD\d)?$'
year_re = re.compile(r'\b\d{4}\b')
year_re = re.compile(r'\d{4}\b')
remove_year_re = re.compile(r'\W*\d{4}\W*')
cdformat_re = re.compile(r'^cd[12]$', re.IGNORECASE)
nameformat_re = re.compile(nameformat_re_str, re.IGNORECASE)

# all lowercase!
garbages = (
    'axxo',
    'bdrip',
    'dvd.screener',
    'dvdrip',
    'dvdscr',
    'jaybob',
    'maxspeed',
    'proper',
    'readnfo',
    'xvid',
    '^sparks-',
)

# all lowercase!
blahdirs = (
    '.unwanted',
    'sample',
    'subs',
)

# all lowercase!
mov_extensions = ('.avi', '.mp4', '.mkv', )
sub_extensions = ('.srt', '.sub', )

unmatched = []


def sanitize(name):
    for garbage in garbages:
        name = re.sub('\W*%s.*' % garbage, '', name, flags=re.IGNORECASE)

    tmp = year_re.findall(name)
    if tmp:
        year = tmp[0]
        name = remove_year_re.sub('', name)
    else:
        year = None

    name = name.replace('_', ' ')
    name = name.replace('&', 'And')
    name = re.sub(r'[^\w,\-\']+', ' ', name).title().replace("'S", "'s")

    if year:
        return '%s {%s}' % (name, year)
    return name


def print_rename(filepath, newname):
    print('mv "%s" "%s"' % (filepath, newname))


def print_cleanup(dirpath):
    print('rm -f "%s"/*' % dirpath)
    print('rmdir "%s"' % dirpath)


def sanitize_path(args, path):
    for (dirpath, dirnames, filenames) in os.walk(path):
        for dirname in dirnames:
            if dirname.lower() in blahdirs:
                dirnames.remove(dirname)
                print('rm -fr "%s/%s"' % (dirpath, dirname))
                print('')
        for filename in filenames:
            filepath = os.path.join(dirpath, filename)
            (basename, ext) = os.path.splitext(filename)
            if ext.lower() in mov_extensions + sub_extensions:
                if ext.lower() in sub_extensions:
                    (tmp_basename, tmp_ext) = os.path.splitext(basename)
                    if tmp_ext.lower() in mov_extensions:
                        basename = tmp_basename
                oldname = basename + ext
                if nameformat_re.match(basename):
                    if not args.quiet:
                        print('# %s' % oldname)
                        print()
                else:
                    sanitized_by_name = sanitize(basename)
                    if not args.quiet:
                        print('# sanitized by name:', sanitized_by_name)

                    dirname = os.path.basename(dirpath)
                    if cdformat_re.match(dirname):
                        cdname = dirname
                        dirname = os.path.basename(os.path.dirname(dirpath))
                    else:
                        cdname = None
                    sanitized_by_dir = sanitize(dirname)
                    if cdname:
                        sanitized_by_dir += ' ' + cdname
                    if not args.quiet:
                        print('# sanitized by dir:', sanitized_by_dir)

                    if nameformat_re.match(sanitized_by_dir):
                        newname = sanitized_by_dir + ext.lower()
                        print_rename(filepath, newname)
                        if dirpath != path:
                            print_cleanup(dirpath)
                    elif nameformat_re.match(sanitized_by_name):
                        newname = sanitized_by_name + ext.lower()
                        print_rename(filepath, newname)
                        if dirpath != path:
                            print_cleanup(dirpath)
                    else:
                        print('# ERROR: could not sanitize "%s"' % filepath)
                        print('# -> "%s" ?' % sanitized_by_name)
                        print('# -> "%s" ?' % sanitized_by_dir)
                    print('')
            else:
                unmatched.append(filepath)


def find_movies_and_fix_year(path):
    baseurl = 'http://pipes.yahoo.com/pipes/pipe.run?_id=0e4ed39f5a532c032a27a61016a50aaa&_render=json&name='
    for dirpath, dirnames, filenames in os.walk(path):
        for filename in filenames:
            oldpath = os.path.join(dirpath, filename)
            work_name, ext = os.path.splitext(filename)
            match = re.search(r'\d{4}', work_name)
            work_name = re.sub(r'[^a-zA-Z]', ' ', work_name)
            work_name = re.sub(r'  +', ' ', work_name)
            title = work_name.strip()

            if title:
                if match:
                    year = match.group(0)
                    newpath = os.path.join(dirpath, '{} [{}]{}'.format(title, year, ext))
                    if oldpath != newpath:
                        print('mv "{}" "{}"'.format(oldpath, newpath))
                    continue
                print('* looking up', title, '...')
                result = requests.get(baseurl + str(title)).json()
                if result['count'] == 0:
                    print('  -> not found')
                    continue
                ''' looks like this:
                x = {'count': 4, 'value': {'callback': '', 'title': 'Get TheMovieDB movie info',
                                           'description': 'Find movies by name on themoviedb.org and extract basic movie info such as exact title and year.',
                                           'link': 'http://pipes.yahoo.com/pipes/pipe.info?_id=0e4ed39f5a532c032a27a61016a50aaa',
                                           'items': [
                                               {'year': '2013', 'title': 'Ip Man: The Final Fight', 'year_sane': 'true', 'description': None},
                                               {'year': '2010', 'title': 'Ip Man 2', 'year_sane': 'true', 'description': None},
                                               {'year': '2010', 'title': 'The Legend Is Born: Ip Man', 'year_sane': 'true', 'description': None},
                                               {'year': '2008', 'title': 'Ip Man', 'year_sane': 'true', 'description': None}
                                           ], 'generator': 'http://pipes.yahoo.com/pipes/', 'pubDate': 'Wed, 19 Nov 2014 19:05:24 +0000'}}
                '''
                items = result['value']['items']
                comment = '' if len(items) == 1 else '# '
                for item in items[:4]:
                    print_item(item)
                    year = item['year']
                    newpath = os.path.join(dirpath, '{} [{}]{}'.format(title, year, ext))
                    print('{}mv "{}" "{}"'.format(comment, oldpath, newpath))


def print_item(item):
    print('  {} [{}]'.format(item['title'], item['year']))


def main():
    parser = argparse.ArgumentParser(description='Normalize movie filenames')
    parser.add_argument('paths', nargs='+')
    parser.add_argument('-n', '--dry-run', '-q', action='store_true')

    args = parser.parse_args()

    for path in args.paths:
        path = os.path.normpath(path)
        # sanitize_path(args, path)
        find_movies_and_fix_year(path)

    for path in unmatched:
        print('# unmatched:', path)

if __name__ == '__main__':
    main()
