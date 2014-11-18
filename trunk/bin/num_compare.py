#!/usr/bin/python
# Filename: num_compare.py
# Function: Compare two num
# coding:utf-8
# Author: Will
# python num_compare.py -sn 1 -cn 2 

import re, argparse, sys

def debug(mesage, is_debug=True):
    if mesage and is_debug:
        print 'DEBUG',
        print mesage

parse = argparse.ArgumentParser(description='number compare')
parse.add_argument('-sn', '--standardnum', required=True, type=float, dest='standard_num',
                    help='standard number')

parse.add_argument('-so', '--standardoperator', required=False, default='+', dest='standard_operator',
                    help='standard operator')

parse.add_argument('-sv', '--standardvalue', required=False, type=float, default=0,dest='standard_value',
                    help='standard value')

parse.add_argument('-cn', '--comparenum', required=True, type=float, dest='compare_num',
                    help='compare number')

parse.add_argument('-co', '--compareoperator', required=False, default='+', dest='compare_operator',
                    help='compare operator')

parse.add_argument('-cv', '--comparevalue', required=False, type=float, default=0,dest='compare_value',
                    help='compare value')

parse.add_argument('-v', '--value', type=float, default=0, dest='value',
                    help='total value')

parse.add_argument('-e', '--error', required=False, default=0, type=float, dest='error',
                    help='error')

parse.add_argument('-m', '--mode', required=False, default='int', dest='mode',
                    help='output format')

parse.add_argument('-debug', '--debug', required=False, default=False, action='store_true', dest='is_debug',
                    help='enable debug mode')

def main():
    args = parse.parse_args() 
    sn = args.standard_num
    so = args.standard_operator
    sv = args.standard_value
    cn = args.compare_num
    co = args.compare_operator
    cv = args.compare_value
    value = args.value
    error = args.error
    mode = args.mode
    is_debug = args.is_debug
    if so == '+':
        debug('Standard enter to + process...', is_debug)
        sn = sn + sv
    elif so == '-':
        debug('Standard enter to - process...', is_debug)
        sn = sn - sv    
    elif so == '*':
        debug('Standard enter to * process...', is_debug)
        sn = sn * sv
    elif so == '/':
        debug('Standard enter to / process...', is_debug)
        sn = sn / sv

    if co == '+':
        debug('Standard enter to + process...', is_debug)
        cn = cn + cv
    elif co == '-':
        debug('Standard enter to - process...', is_debug)
        cn = cn - cv    
    elif co == '*':
        debug('Standard enter to * process...', is_debug)
        cn = cn * cv
    elif co == '/':
        debug('Standard enter to / process...', is_debug)
        cn = cn / cv
    range_begin = sn - value * error
    range_end = sn + value * error
    if cn > range_end:
        if mode == 'int':
            print '%s is more than %s + allowed error' % (int(cn), int(sn))
        else:
            print '%s is more than %s + allowed error' % (cn, sn)
    elif cn < range_begin:
        if mode == 'int':
            print '%s is less than %s - allowed error' % (int(cn), int(sn))
        else:
            print '%s is less than %s - allowed error' % (cn, sn)
    elif cn >= range_begin and cn <= range_end:
        if mode == 'int':
            print '%s is in the range of %s and allowed error' % (int(cn), int(sn))
        else:
            print '%s is in the range of %s and allowed error' % (cn, sn)
    
if __name__ == '__main__':
    try:
        compare = main()
    except Exception, e:
        print str(e)
        sys.exit(1)
