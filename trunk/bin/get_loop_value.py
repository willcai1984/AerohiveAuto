#!/usr/bin/python
# Filename: get_loop_value.py
# Function: get loop value from x:y
# -*- coding: UTF-8 -*-
# Author: Will

import re, argparse, sys

def debug(mesage, is_debug=True):
    if mesage and is_debug:
        print 'DEBUG',
        print mesage

parse = argparse.ArgumentParser(description='''Get the loop value from x:y''')

parse.add_argument('-s', '--string', required=False, default='', dest='loop_str',
                    help='Loop value string')

parse.add_argument('-p', '--position', required=False, type=int, default=1, dest='position',
                    help='''The value which you want to get''')

parse.add_argument('-o', '--operator', required=False, default='+', choices=['+', '-', '*', '/'], dest='operator',
                    help='operator of the base value')

parse.add_argument('-v', '--value', required=False, default='0', dest='value',
                    help='operate base value, position value + operator + base value')

parse.add_argument('-hex', '--hex', required=False, default=False, action='store_true', dest='is_hex',
                    help='return hex format')

parse.add_argument('-c', '--casesensitive', required=False, default='none', choices=['upper', 'lower', 'none'], dest='case_sensitive',
                    help='case sensitive of the output')

parse.add_argument('-f', '--format', required=False, default=0, dest='format',
                    help='the out put format')

parse.add_argument('-debug', '--debug', required=False, default=False, action='store_true', dest='is_debug',
                    help='enable debug mode')


def main():
    args = parse.parse_args() 
    loop_str = args.loop_str
    position = args.position
    operator = args.operator
    value = args.value
    case_sensitive = args.case_sensitive
    is_debug = args.is_debug
    is_hex = args.is_hex
    format = int(args.format)
    loop_para_list = loop_str.split(':')
    if position > len(loop_para_list):
        print 'The position parameter is to large'
        return None
    loop_value = loop_para_list[int(position) - 1]
    if operator == '+':
        debug('Enter to + process...', is_debug)
        real_value = int(loop_value) + int(value)
    elif operator == '-':
        debug('Enter to - process...', is_debug)
        real_value = int(loop_value) - int(value)    
    elif operator == '*':
        debug('Enter to * process...', is_debug)
        real_value = int(loop_value) * int(value)
    elif operator == '/':
        debug('Enter to / process...', is_debug)
        real_value = int(loop_value) / int(value)
    if format:
        if is_hex:
            format_cli='%0'+str(format)+'x'
        else:
            format_cli='%0'+str(format)+'d'
    else:
        if is_hex:
            format_cli='%x'
        else:
            format_cli='%d'  
    real_value = format_cli % int(real_value)
        
    if case_sensitive == 'none':
        pass
    elif case_sensitive == 'upper':
        real_value = real_value.upper()
    elif case_sensitive == 'lower':
        real_value = real_value.lower()
        
    return real_value
   
if __name__ == '__main__':
    try:
        get_result = main()
        if get_result == None:
            sys.exit(1)
        else:
            print get_result
            sys.exit(0)
    except Exception, e:
        print str(e)
        sys.exit(1)
        
