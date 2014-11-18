#!/usr/bin/python

import re, sys, argparse

def debug(msg, debug=True):
    if args.debug:
        if msg and debug:
            print 'DEBUG',
        print msg

# return patterns in [(pattern, occurrence, script), ...] or raise exception if parameter is wrong
def parse_patterns(patterns):
    ps = []

    msg = 'patterns error'

    i = 0
    while i < len(patterns):
        occ = patterns[i]
        if re.match('p\d*', occ) is None:
            raise Exception(msg)
        occ = occ.replace('p', '>0') if occ == 'p' else occ.replace('p', '==')
        i += 1
        pattern = patterns[i]
        i += 1
        if i < len(patterns):
            script = patterns[i]
            if not re.match('p\d*', script):
                i += 1
                ps.append((pattern, occ, script))
                continue
        ps.append((pattern, occ, None))

    for (p, occ, script) in ps:
        debug('%s: desired occurrence%s and script is %s' % (p, occ, script))

    return ps

# check the patterns to ensure the occurrence is same to desired
def check_patterns(actual, desired):
    ok_count = 0
    nok_count = 0

    for (p, occ, script) in desired:
        msg = '%s: desired occurrence%s, actual %d' % (p, occ, actual[p])

        if eval('%d%s' % (actual[p], occ)):
            ok_count += 1
            debug(msg + ' OK')
        else:
            nok_count += 1
            debug(msg + ' NOK')

    debug('%d patterns, %d OK, %d NOK' % (len(desired), ok_count, nok_count))

    if nok_count:
        return False
    else:
        return True

# check the patterns against one line
def check_line(line, patterns, dictOcc):
    msg = []

    for (p, occ, script) in patterns:
        m = re.search(p, line)
        if m and (script is None or eval(script)):
            dictOcc[p] += 1
            msg.append(p)

    if msg:
        debug(line + ' --> ' + ','.join(msg))

    return dictOcc

# reset cached occurrences
def reset_occ(patterns, dictOcc):
    for (p, occ, script) in patterns:
        dictOcc[p] = 0
    return dictOcc

parser = argparse.ArgumentParser(description = 'this is description of %(prog)s')

parser.add_argument('-d', '--debug', required=False, default=False, dest='debug', action='store_true',
                    help='debug msg')

parser.add_argument('-b', '--begin_pattern', required=False, default=None, dest='begin_pattern',
                    help='regular expression to begin')

parser.add_argument('-nb', '--no_begin_pattern', required=False, default=False, dest='no_begin_pattern', action='store_true',
                    help='do not search in begin pattern')

parser.add_argument('-ps', required=True, dest='patterns', nargs='+',
                    help='regular expressions and occurrences')

parser.add_argument('-e', '--end_pattern', required=False, default=None, dest='end_pattern',
                    help='regular expression to end')

parser.add_argument('-ne', '--no_end_pattern', required=False, default=False, dest='no_end_pattern', action='store_true',
                    help='do not search in end pattern')

parser.add_argument('-f', '--file', required=True, dest='file_name',
                    help='file to be searched in')

if __name__ == '__main__':
    ret = False

    args = parser.parse_args()

    if args.begin_pattern:
        if args.no_begin_pattern:
            debug('begin pattern (excluded): %s' % args.begin_pattern)
        else:
            debug('begin pattern (included): %s' % args.begin_pattern)
    debug('pattern to find:%s' % args.patterns)
    if args.end_pattern:
        if args.no_end_pattern:
            debug('end pattern (excluded): %s' % args.end_pattern)
        else:
            debug('end pattern (included): %s' % args.end_pattern)
    debug('file to find: %s' % args.file_name)

    patterns = parse_patterns(args.patterns)
    dictOcc = reset_occ(patterns, {})
    begin = False if args.begin_pattern else True
    end = False
    debug('')

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
                    debug('begin pattern matched:')
                    debug(line + ' --> ' + line[m.start():m.end()])
                    if args.no_begin_pattern:
                        debug('start to search from next line')
                        continue
                    else:
                        debug('start to search from this line')

            if begin and end == False and args.end_pattern:
                m = re.search(args.end_pattern, line)
                if m:
                    if args.no_end_pattern:
                        end = True
                    else:
                        end = 'scheduled'

            if begin and end != True :
                check_line(line, patterns, dictOcc)

            if end == True or end == 'scheduled':
                debug('end pattern matched:')
                debug(line + ' --> ' + line[m.start():m.end()])
                debug('stop to search accordingly')
                if check_patterns(dictOcc, patterns):
                    debug('all patterns matched as desired')
                    ret = True
                    break
                else:
                    debug('not all patterns matched as desired')
                    reset_occ(patterns, dictOcc)
                    begin = False if args.begin_pattern else True
                    end = False
                    debug('')
                    continue

        try:
            f.close()
        except:
            pass

        if end == False:
            debug('end of file reached')
            if not args.end_pattern:
                if check_patterns(dictOcc, patterns):
                    debug('all patterns matched as desired')
                    ret = True
                else:
                    debug('not all patterns matched as desired')

        debug('')

        if ret:
            print 'success'
            sys.exit(0)
        else:
            print 'fail'
            sys.exit(1)
