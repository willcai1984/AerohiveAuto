#!/usr/bin/python
# Filename: list_Compare.py
# Function: Compare two list and print the add/remove parameters,return a dict, the value means appear times, if it is negative, means the standard list not has the item 
# coding:utf-8
# Author: Will
# python list_compare.py -sf '1.txt' -cf '2.txt' 

import re, argparse, sys

def debug(mesage, is_debug=True):
    if mesage and is_debug:
        print 'DEBUG',
        print mesage
        
def list_compare(list_standard, list_compare):
    dict_standard = {}
    for i_key in list_standard:
        dict_standard[i_key] = 0
    dict_compare = {}
    for j_key in list_compare:
#if list_standard not has the key,may raise the KeyError
        try:
            j_appear = dict_standard[j_key]
        except KeyError:
            j_appear = -1
        else:
            j_appear += 1
            dict_standard[j_key] = j_appear
        dict_compare[j_key] = j_appear
#Merger the two dicts  
    Tuple_Merger = dict_standard.items() + dict_compare.items()
    dict_Merger = {}
    for i_tuple_key, i_tuple_value in Tuple_Merger:
        dict_Merger[i_tuple_key] = i_tuple_value
    return dict_Merger

parse = argparse.ArgumentParser(description='list compare')
parse.add_argument('-sf', '--standardfile', required=True, dest='standard_file',
                    help='standard file path')

parse.add_argument('-cf', '--comparefile', required=True, dest='compare_file',
                    help='compare file path')

parse.add_argument('-debug', '--debug', required=False, default=False, action='store_true', dest='is_debug',
                    help='enable debug mode')

def main():
    args = parse.parse_args() 
    sf = args.standard_file
    cf = args.compare_file
    is_debug=args.is_debug
    try:
        with open(sf, mode='r') as sf_open:
            sf_list = sf_open.readlines()
    except IOError:
        print '''No such file or directory: '%s', please check ''' % sf
        sys.exit(0)
    try:
        with open(cf, mode='r') as cf_open:
            cf_list = cf_open.readlines()
    except IOError:
        print '''No such file or directory: '%s', please check ''' % sf
        sys.exit(0)
    compare_result_dict = list_compare(sf_list, cf_list)
    debug('compare_result_dict is %s' % compare_result_dict,is_debug)
    standard_only_list = []
    compare_only_list = []
    more_list = []
    for value, key in compare_result_dict.items():
        if int(key) == 1:
            debug('The value %s occurs 1 time' % value,is_debug)
        elif int(key) == 0:
            debug('The value %s not occurs in compare list' % value,is_debug)
            standard_only_list.append(value)
        elif key < 0:
            debug('The value %s not occurs in standard list' % value,is_debug)
            compare_only_list.append(value)
        elif int(key) > 1:
            debug('The value %s occurs more than 1 times' % value,is_debug)
            more_list.append(value)
    return standard_only_list,compare_only_list,more_list

if __name__=='__main__':
    try:
        standard_only_list,compare_only_list,more_list=main()
        if standard_only_list:
            print '''--- %s ''' % str(sorted(standard_only_list))
            sys.exit(1)
        elif compare_only_list:
            print '''+++ %s ''' % str(sorted(compare_only_list))
            sys.exit(1)
        elif more_list:
            print '''These parameters %s occur more than 1 times''' % str(sorted(more_list))
            sys.exit(1)
        else:
            print '''The two lists are the same '''
            sys.exit(0)
    except Exception,e:
        print str(e)
        sys.exit(1)
