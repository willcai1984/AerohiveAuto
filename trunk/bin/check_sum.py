#!/usr/bin/python
# Filename: check_num.py
# Function: check if two list's sum is equal
# -*- coding: UTF-8 -*-
# Author: Well
# Example command:python get_ixia_pkt.py -f test.log -r 1.2.2/python test.py -f test.log -t 1.2.3
import re,argparse,sys,os

def debug(mesage, is_debug=True):
    if mesage and is_debug:
        print 'DEBUG',
        print mesage

def list_sum(execute_list,is_debug=False):
    list_sum=0
    for i in execute_list:
        try:
            i=int(i)
        except ValueError:
            print 'Value Error, pls check your list'
            return None
        else:
            list_sum+=i
    return list_sum

parse = argparse.ArgumentParser(description='''Check if two list's sum is the same''')

parse.add_argument('-s', '--standard', required=False,default=[], action='append', dest='sta_list',
                    help='transmit port')

parse.add_argument('-c', '--compare', required=False,default=[], action='append', dest='com_list',
                    help='receive port')

parse.add_argument('-debug', '--debug', required=False, default=False,action='store_true', dest='is_debug',
                    help='enable debug mode')

def main():
    args = parse.parse_args() 
    sta_list=args.sta_list
    com_list=args.com_list
    is_debug=args.is_debug
    sta_sum=list_sum(sta_list)
    com_sum=list_sum(com_list)
    if sta_sum == com_sum:
        print "The two lists' sum are the same"
        return 1
    elif sta_sum > com_sum:
        print "Standard list's sum is more than compare list's"
        return 1
    elif sta_sum < com_sum:
        print "Standard list's sum is less than compare list's"
        return 1
    else:
        return 0
if __name__=='__main__':
    try:
        check_result=main()
        if check_result:
            sys.exit(0)
        else:
            print '''Unknow error'''
            sys.exit(1)
    except Exception,e:
        print str(e)
        sys.exit(1)
        