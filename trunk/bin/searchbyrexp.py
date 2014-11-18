#!/usr/bin/python

import argparse, sys, re
from datetime import datetime, timedelta
from time import mktime

parser = argparse.ArgumentParser(description='search pattern from specified file')

parser.add_argument('-b', '--begin_pattern', required=False, default=None, dest='begin_pattern',
                    help='regular expression to begin')

parser.add_argument('-nb', '--no_begin_pattern', required=False, default=False, dest='no_begin_pattern', action='store_true',
                    help='do not search in begin pattern')

parser.add_argument('-p', '--pattern', required=True, dest='pattern',
                    help='regular expression')

parser.add_argument('-e', '--end_pattern', required=False, default=None, dest='end_pattern',
                    help='regular expression to end')

parser.add_argument('-ne', '--no_end_pattern', required=False, default=False, dest='no_end_pattern', action='store_true',
                    help='do not search in end pattern')

parser.add_argument('-f', '--file', required=True, dest='file_name',
                    help='file to be searched in')

parser.add_argument(      '--script', required=False, default=None, dest='script',
                    help='script to handle matched string, return value should be True')

parser.add_argument('-c', '--occurrences', required=False, default='exists', dest='occurrences',
                    help='exit status is 0 only if count of occurrences matched:'
                         ' exists - exit 0 if pattern occurred')

if __name__ == '__main__':
    args = parser.parse_args()

    if args.begin_pattern:
        if args.no_begin_pattern:
            print 'begin pattern (excluded): %s' % args.begin_pattern
        else:
            print 'begin pattern (included): %s' % args.begin_pattern
    print 'pattern to find: %s' % args.pattern
    if args.end_pattern:
        if args.no_end_pattern:
            print 'end pattern (excluded): %s' % args.end_pattern
        else:
            print 'end pattern (included): %s' % args.end_pattern
    print 'file to find: %s' % args.file_name
    if args.script: print 'script: %s' % args.script
    print 'count of occurrences: %s' % args.occurrences
    print ''

    begin = False if args.begin_pattern else True
    end = False if args.begin_pattern else False

    count = 0
    try:
        f = open(args.file_name, 'r')
    except:
        print 'error occurred:', sys.exc_info()[1]
        sys.exit(2)
    else:
        for line in f:
            line = line.replace(' '*28, '').rstrip('\n').rstrip('\r')

            if not begin and args.begin_pattern:
                m = re.search(args.begin_pattern, line)
                if m:
                    begin = True
                    print 'begin pattern matched'
                    print line, ' --> ', line[m.start():m.end()]
                    if args.no_begin_pattern:
                        print 'start to search from next line'
                        print ''
                        continue
                    else:
                        print 'start to search from this line'
                        print ''

            if begin and not end and args.end_pattern:
                m = re.search(args.end_pattern, line)
                if m:
                    end = True
                    if args.no_end_pattern:
                        print ''
                        print 'end pattern matched'
                        print line
                        print 'stop to search immediately'
                        break

            if begin:
                m = re.search(args.pattern, line)
                if m:
                    print line, ' --> ', line[m.start():m.end()],
                    if args.script:
                        if eval(args.script) == True:
                            count += 1
                            print ' - ok, returned True'
                        else:
                            print ' - not ok, returned Not True'
                    else:
                        count += 1
                        print ''

            if end:
                print ''
                print 'end pattern matched'
                print line
                print 'stop to search accordingly'
                break

        try:
            f.close()
        except:
            pass

        if args.begin_pattern and begin == False:
            print ''
            print 'fail:', 'no begin pattern found'
            sys.exit(1)

        if args.end_pattern and end == False:
            print ''
            print 'fail:', 'no end pattern found'
            sys.exit(1)

        print ''
        print 'total %d occurrences' % count

        msg = 'pattern matched %d times, expect %s' % (count, args.occurrences)
        if (count and args.occurrences == 'exists') or (str(count) == args.occurrences):
            print 'success:', msg
            sys.exit(0)
        else :
            print 'fail:', msg
            sys.exit(1)

# dt = datetime.strptime('2011-12-31 20:28:16', '%Y-%m-%d %H:%M:%S')
# d = timedelta(minutes=5)
# (dt + d).strftime('%Y-%m-%d %H:%M:%S')