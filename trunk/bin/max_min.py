#!/usr/bin/python
# Filename: max_min.py
# Function: get the max and min of the string
# -*- coding: UTF-8 -*-
# Author: Will
# Example: python max_min.py -s "('2','3','4')" -e 'max'
'''
[root@hzaptb1-mpc bin]# python max_min.py -s "(1,2,3,4,5)" -e 'max'
5
[root@hzaptb1-mpc bin]# python max_min.py -s "(1,2,3,4,5)" -e 'min'
1
[root@hzaptb1-mpc bin]# python max_min.py -s "(1,2,3,4,5)" -e 'nomin'
['2', '3', '4', '5']
[root@hzaptb1-mpc bin]# python max_min.py -s "(1,2,3,4,5)" -e 'nomaxmin'
['2', '3', '4']
[root@hzaptb1-mpc bin]# python max_min.py -s "(1,2,3,4,5)" -e 'nomax'
['1', '2', '3', '4']
'''


import re, argparse, sys

def debug(mesage, is_debug=True):
    if mesage and is_debug:
        print 'DEBUG',
        print mesage

parse = argparse.ArgumentParser(description='''Get the string's max or min''')

parse.add_argument('-s', '--str', required=False, default='', dest='operate_str',
                    help='''operate string, for example "('2','3','4')" ''')

parse.add_argument('-e', '--expect', required=False, default='max', dest='expect', choices=['max', 'min', 'nomax', 'nomin', 'nomaxmin'],
                    help='the value you want to get, max or min or nomax or nomin or nomaxmin')

parse.add_argument('-debug', '--debug', required=False, default=False, action='store_true', dest='is_debug',
                    help='enable debug mode')


def main():
    args = parse.parse_args()
    operate_str = args.operate_str
    expect = args.expect
    is_debug = args.is_debug
    operate_list = re.sub('\(|\)', '', operate_str).split(',')
    debug('Operate list is %s' % str(operate_list), is_debug)
    value = ''
    if expect == 'max':
        value = max(operate_list)
    elif expect == 'min':
        value = min(operate_list)
    elif expect == 'nomax':
        max_value = max(operate_list)
        value = str([i for i in operate_list if i != max_value])
    elif expect == 'nomin':
        min_value = min(operate_list)
        value = str([i for i in operate_list if i != min_value])
    elif expect == 'nomaxmin':
        max_value = max(operate_list)
        min_value = min(operate_list)
        value = str([i for i in operate_list if i != min_value and i != max_value])          
    return value
    

   
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
        
