#!/usr/bin/python

import argparse, sys, re, time
from datetime import datetime, timedelta
from time import mktime

parser = argparse.ArgumentParser(description='evaluate python script')

parser.add_argument('script',
                    help='script to be evaluated')

parser.add_argument(      '--amode', required=False, default=False, dest='amode', action='store_true',
                    help='assertion mode: exit status is 0 only if return value of script is True')

parser.add_argument('-d', '--debug', required=False, default=False, dest='debug', action='store_true',
                    help='debug msg')

def debug(msg, debug=True):
    if args.debug:
        if msg and debug:
            print 'DEBUG',
        print msg

if __name__ == '__main__':
    args = parser.parse_args()

    debug('script to be evaluated: %s' % args.script)
    debug('assertion mode: %s' % args.amode)
    debug('')

    try:
        ret = eval(args.script)
        debug('return value of script: %s' % str(ret))
        debug('')
    except:
        debug('error occurred: %s' % sys.exc_info()[1])
        sys.exit(2)
    else:
        if args.amode:
            if ret == True:
                debug('assertion successful')
                sys.exit(0)
            else:
                debug('assertion failed')
                sys.exit(1)
        else:
            sys.stdout.write(str(ret))
            sys.exit(0)