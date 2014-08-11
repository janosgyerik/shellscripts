#!/usr/bin/env python

import os
import sys
import datetime
import shutil

changes_dir = 'change-scripts'
profiles_dir = 'profiles'
version_file = 'version.txt'
sqlcmd_file = 'sqlcmd.txt'

profile = None
batch_mode = False


'''Print the "README"
    '''
def readme():
    print '''
    The "README"
    ============
    This program helps synchronizing database schemas. For every schema change,
    you should write 'change scripts', and apply them using this program.
    The program will keep track of the change scripts, and the order in which
    they were executed. It will also keep track of the last change script
    executed for a database, so that only new scripts are applied to each
    database, and each script is applied only once.
    
    How to get started?
    -------------------
    1. Create a database (dev)

    2. Create a database user with sysadmin Server Role
	* It is advised to dedicate a user for this program
	* Use a very secure password. On the other hand, it will have to be 
	  written to a config file, which is of course not very secure.
	  It may be advised to change the password periodically.

    3. Create directory: profiles/dev

    4. Create file: profiles/dev/sqlcmd.txt
	* Add a single line with the shell command to execute an sql script
	* The defined command will be executed as: CMD file.sql
	* Example: sqlcmd -S servername -U username -P "pw" -d dbname -e -p -i
	* Example: isql -S servername -U username -P "pw" -D dbname -e -Jsjis -i

    5. Run database init scripts, make sure they work, or fix them now.
	* Example: 
	    %(cmd)s run dev create-tables.sql
	    %(cmd)s run dev create-views.sql
	    %(cmd)s run dev create-users.sql
	    ...

    6. Import database init scripts, to be tracked as 'change scripts'
	* Example: 
	    %(cmd)s import create-tables.sql
	    %(cmd)s import create-views.sql
	    ...
	* Important: you probably don't want to import user init scripts.
	  The reason is, you should have different passwords in dev/uat/prod
	  environments. So, DO NOT import user init scripts!

    7. Now the scripts are ready to be applied to another database.
	* Create directory: profiles/uat
	* Create file: profiles/uat/sqlcmd.txt
	* Apply change scripts:
	    %(cmd)s sync uat
	* Run user init scripts
	    %(cmd)s run uat create-users.sql

    8. What about the first database (dev)? All the change scripts were run on 
       it, and they should not run again. You want to mark the database 
       profile to be up to date, but without applying change scripts.
	* Run:
	    %(cmd)s sync-markonly dev

    9. You probably want to add the change scripts to version control.
    ''' % { 'cmd': os.path.basename(__file__) }


''' Setup environment:
    * make sure changes_dir exists
    * make sure profiles_dir exists
    '''
def setup():
    if not os.path.isdir(changes_dir):
	os.mkdir(changes_dir)

    if not os.path.isdir(profiles_dir):
	os.mkdir(profiles_dir)


''' Import files in the directory structure of change-scripts. '''
def import_scripts(files):
    for f in files:
	if not os.path.exists(f):
	    print 'Warning: file "%s" does not exist' % f
	    continue

	today = datetime.date.today()
	num = 1
	daydir = '%s/%04d%02d%02d' % (changes_dir, today.year, today.month, today.day)
	if not os.path.isdir(daydir):
	    os.mkdir(daydir)
	num += len(os.listdir(daydir))
	
	f2 = '%s/%02d-%s' % (daydir, num, os.path.basename(f))
	print 'Importing file "%s" as "%s"' % (f, f2)
	shutil.copy2(f, f2)


''' Validate profile, raise error if invalid.'''
def require_profile():
    if profile is None:
	print 'Error: specify profile with -p PROFILE or --profile PROFILE'
	sys.exit(1)


''' Apply new change scripts (or all of them). '''
def sync(testonly):
    require_profile()
    version = get_version()
    if version is None:
	info('Version does not exist or invalid. All change scripts will be applied.')
	dname = ''
	fname = ''
    else:
	dname = version[0]
	fname = version[1]

    for d in os.listdir(changes_dir):
	if dname > d:
	    continue
	if d[0] == '.':
	    continue
	p = '%s/%s' % (changes_dir, d)
	if os.path.isdir(p):
	    for f in os.listdir(p):
		if dname == d and fname >= f:
		    continue
		if valid_version_file(d, f):
		    if testonly:
			info('%s\t%s' % (d, f))
		    else:
			if not runsql(d, f): break


''' Mark the profile as if it has all the change scripts applied.'''
def sync_markonly():
    require_profile()
    for d in os.listdir(changes_dir):
	if d[0] == '.':
	    continue
	p = '%s/%s' % (changes_dir, d)
	if os.path.isdir(p):
	    for f in os.listdir(p):
		if valid_version_file(d, f):
		    dname = d
		    fname = f

    set_version(d, f)


''' Print a list of change scripts.'''
def list_scripts():
    for d in os.listdir(changes_dir):
	if d[0] == '.':
	    continue
	p = '%s/%s' % (changes_dir, d)
	if os.path.isdir(p):
	    for f in os.listdir(p):
		if valid_version_file(d, f):
		    info('%s\t%s' % (d, f))


''' Pause until user presses ENTER.'''
def pause():
    print
    raw_input("[ Press ENTER to proceed ]\n")


''' Run specified change script.'''
def runsql(dname, fname):
    require_profile()
    sqlcmd = get_sqlcmd();
    if sqlcmd is None:
	return
    cmd = '%s %s/%s/%s' % (sqlcmd, changes_dir, dname, fname)
    info('Executing script: %s %s/%s' % (profile, dname, fname))
    r = os.system(cmd)
    if not batch_mode: pause()
    if r == 0:
	set_version(dname, fname)
	return True
    else:
    	return None


''' Run specified SQL scripts one by one.'''
def runsql_files(files):
    require_profile()
    sqlcmd = get_sqlcmd();
    if sqlcmd is None:
	return
    for f in files:
	if os.path.isfile(f):
	    cmd = '%s %s' % (sqlcmd, f)
	    info('Executing script: %s %s' % (profile, f))
	    if os.system(cmd) != 0: break
	    if not batch_mode: pause()


''' Evaluate if change script file exists or not.'''
def valid_version_file(dname, fname):
    if not os.path.exists('%s/%s/%s' % (changes_dir, dname, fname)):
	info('Invalid version: file does not exist: %s/%s' % (dname, fname))
	return

    if not os.path.isfile('%s/%s/%s' % (changes_dir, dname, fname)):
	info('Invalid version: path is not a file: %s/%s' % (dname, fname))
	return

    try:
	revno = fname[:fname.index('-')]
	return len(revno) == 2 and revno[0] >= '0' and revno[0] <= '9' and revno[1] >= '0' and revno[1] <= '9'

    except Exception, e:
	info('Invalid version: %s/%s %s' % (dname, fname, e))


''' Gets the version, as the first line in the version file, validated.'''
def get_version():
    try:
	f = open(get_version_filepath())
	tmp = f.readline().rstrip()
	v1 = os.path.dirname(tmp)
	v2 = os.path.basename(tmp)
	if valid_version_file(v1, v2):
	    return (v1, v2)

    except Exception, e:
	info('Invalid version due to exception: %s' % e)


def get_profile_dir():
    return '%s/%s' % (profiles_dir, profile)


def get_version_filepath():
    return '%s/%s' % (get_profile_dir(), version_file)


def get_sqlcmd_filepath():
    return '%s/%s' % (get_profile_dir(), sqlcmd_file)


def get_sqlcmd():
    require_profile()
    try:
	f = open(get_sqlcmd_filepath())
	return f.readline().rstrip()

    except Exception, e:
	info('Could not load sqlcmd: %s' % e)


def validate_profile_dir():
    d = get_profile_dir()
    if not os.path.isdir(d):
	os.mkdir(d)


def set_version(dname, fname):
    validate_profile_dir()
    filepath = get_version_filepath()
    f = open(filepath, 'w')
    f.write('%s/%s' % (dname, fname))
    info('Set version for profile = %s, %s/%s' % (profile, dname, fname))


def info(msg):
    print '[ii] %s' % msg


if __name__ == '__main__':
    from optparse import OptionParser
    usage = 'usage: %prog [options] cmd [args]\n\nCommands:\n'
    usage += '  readme\n'
    usage += '  list\n'
    usage += '  import SCRIPT.sql\n'
    usage += '  sync -p PROFILE\n'
    usage += '  sync-dryrun -p PROFILE\n'
    usage += '  sync-markonly -p PROFILE\n'
    usage += '  run -p PROFILE SCRIPT.sql'
    parser = OptionParser(usage = usage)
    parser.add_option("-b", help="Set batch mode", dest="batch", default=False, action="store_true")
    parser.add_option("-p", help="Set database profile to use", dest="profile")
    (options, args) = parser.parse_args()
    batch_mode = options.batch
    profile = options.profile

    if len(args) < 1:
	print 'Error: you did not specify a cmd'
	parser.print_help()
	sys.exit(1)

    setup()

    cmd = args[0]

    if cmd == 'run':
	runsql_files(args[1:])
    elif cmd == 'list':
	list_scripts()
    elif cmd == 'import' or cmd == 'im':
	import_scripts(args[1:])
    elif cmd == 'dryrun' or cmd == 'pending' or cmd == 'test':
	sync(True)
    elif cmd == 'sync' or cmd == 'upgrade' or cmd == 'up':
	sync(False)
    elif cmd == 'sync-markonly' or cmd == 'sync-mark':
	sync_markonly()
    elif cmd == 'readme':
	readme()
    else:
	print 'Unknown command: ' + cmd


# eof
