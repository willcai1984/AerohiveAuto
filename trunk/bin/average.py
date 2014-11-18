#!/usr/bin/python
# Filename: average.py
# Function: remove max value, remove min value, get the average value of the string
# -*- coding: UTF-8 -*-
# Author: Will
# Modify: Daliz
# Example: 'python average.py -s "(111,2.22,3,4,5)" -b '2''
'''
'''


import re, argparse, sys

def debug(mesage, is_debug=True):
    if mesage and is_debug:
        print 'DEBUG',
        print mesage

parse = argparse.ArgumentParser(description='''Get the string's max or min''')

parse.add_argument('-s', '--str', required=False, default='', dest='operate_str',
                    help='''operate string, for example "('2','3','4')" ''')

parse.add_argument('-b', '--bits', required=False, default='2', dest='bits',
                    help='correct the value to specified decimal places')

parse.add_argument('-debug', '--debug', required=False, default=False, action='store_true', dest='is_debug',
                    help='enable debug mode')


def main():
    args = parse.parse_args()
    operate_str = args.operate_str
    bits = args.bits
    is_debug = args.is_debug
    operate_list = re.sub('\(|\)', '', operate_str).split(',')
    debug('Operate list is %s' % str(operate_list), is_debug)
    operate_list=[float(i) for i in operate_list]
    max_value = max(operate_list)
    min_value = min(operate_list)
    debug('Max is %s' % max_value,is_debug)
    debug('Min is %s' % min_value,is_debug)
    #following can remove all same value if they are MAX/MIN
    #value_list = [i for i in operate_list if i != min_value and i != max_value]
    operate_list.remove(max_value)
    operate_list.remove(min_value)
    value_list = operate_list
    debug('Value_list is %s' % str(value_list),is_debug)
    return round(sum([float(i) for i in value_list])/len(value_list),int(bits))



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
