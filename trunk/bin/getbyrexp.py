#!/usr/bin/python

import argparse, sys, re, time
from datetime import datetime, timedelta
from time import mktime

parser = argparse.ArgumentParser(description='search pattern from specified file')

parser.add_argument('-d', '--debug', required=False, default=False, dest='debug', action='store_true',
                    help='debug msg')

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

parser.add_argument('-t', '--value_type', required=False, default='int', dest='value_type',
                    help='int, str...')

parser.add_argument(      '--script', required=False, default=None, dest='script',
                    help='script to handle matched string, -t is suspended by this option')

parser.add_argument(      '--script_ms', required=False, default=None, dest='script_ms',
                    help='script to handle matches, -s & -g are suspended by this option')

parser.add_argument('-s', '--sort_type', required=False, default='sort', dest='sort_type',
                    help='sort, reverse, sort_reverse, none...')

parser.add_argument('-g', '--get_by_position', type=int, required=False, default=None, dest='get_by_position',
                    help='return value at certain position')

def debug(msg, debug=True):
    if args.debug:
        if msg and debug:
            print 'DEBUG',
        print msg

if __name__ == '__main__':
    args = parser.parse_args()

    if args.begin_pattern:
        if args.no_begin_pattern:
            debug('begin pattern (excluded): %s' % args.begin_pattern)
        else:
            debug('begin pattern (included): %s' % args.begin_pattern)
    debug('pattern to find: %s' % args.pattern)
    if args.end_pattern:
        if args.no_end_pattern:
            debug('end pattern (excluded): %s' % args.end_pattern)
        else:
            debug('end pattern (included): %s' % args.end_pattern)
    debug('file to find: %s' % args.file_name)
    if args.script == None:
        debug('value type: %s' % args.value_type)
    else:
        debug('script: %s' % args.script)
    if args.script_ms == None:
        debug('sort type: %s' % args.sort_type)
        if args.get_by_position == None:
            debug('get by position: joined by comma')
        else:
            debug('get by position: %d' % args.get_by_position)
    else:
        debug('script_ms: %s' % args.script_ms)
    debug('')

    begin = False if args.begin_pattern else True
    end = False if args.begin_pattern else False

    ms = []
    try:
        f = open(args.file_name, 'r')
    except:
        debug('error occurred: %s' % sys.exc_info()[1])
        sys.exit(2)
    else:
        for line in f:
            line = line.replace(' '*28, '').rstrip('\n').rstrip('\r')

            if not begin and args.begin_pattern:
                m = re.search(args.begin_pattern, line)
                if m:
                    begin = True
                    debug('begin pattern matched')
                    debug(line + ' --> ' + line[m.start():m.end()])
                    if args.no_begin_pattern:
                        debug('start to search from next line')
                        debug('')
                        continue
                    else:
                        debug('start to search from this line')
                        debug('')

            if begin and not end and args.end_pattern:
                m = re.search(args.end_pattern, line)
                if m:
                    end = True
                    if args.no_end_pattern:
                        debug('')
                        debug('end pattern matched')
                        debug(line)
                        debug('stop to search immediately')
                        break

            if begin:
                m = re.search(args.pattern, line)
                if m:
                    debug(line + ' --> ' + line[m.start():m.end()])
                    if args.script:
                        ms.append(eval(args.script))
                    else:
                        ms.append(eval('%s("%s")' % (args.value_type, m.group(1))))

            if end:
                debug('')
                debug('end pattern matched')
                debug(line)
                debug('stop to search accordingly')
                break

        try:
            f.close()
        except:
            pass

        if args.begin_pattern and begin == False:
            debug('')
            debug('fail:' + 'no begin pattern found')
            sys.exit(1)

        if args.end_pattern and end == False:
            debug('')
            debug('fail:' + 'no end pattern found')
            sys.exit(1)

        debug('')
        debug('all matched:')
        debug(ms)

        if args.script_ms:
            sys.stdout.write(str(eval(args.script_ms)))
            sys.exit(0)

        if args.sort_type == 'sort':
            ms.sort()
        elif args.sort_type == 'sort_reverse':
            ms.sort(reverse=True)
        elif args.sort_type == 'reverse':
            ms.reverse()
        else:
            pass

        debug('')
        debug('after %s:' % args.sort_type)
        debug(ms)
        debug('')

        if ms:
            if args.get_by_position == None:
                sys.stdout.write(','.join([str(m) for m in ms]))
            else:
                sys.stdout.write(str(ms[args.get_by_position]))
            sys.exit(0)
        else:
            sys.exit(1)
