#!/usr/bin/env python
# path: /auto_case/bin/
# Filename: matchbyrexp.py
# Function: Search the file and print the match line info
# coding:utf-8
# Topo: LinuxPC
# Author: Well

import argparse, sys, re
parser = argparse.ArgumentParser(description = 'Search the file and print the match line info')

parser.add_argument('-d', '--deststa', required=True, default=None, dest='ipAddress',
                    help='Destination AP')

parser.add_argument('-u', '--user', required=True, default=None, dest='loginName',
                    help='User name')

parser.add_argument('-p', '--password', required=True, default=None, dest='loginPassword',
                    help='User password')

parser.add_argument('-c', '--command', required=True, default=0, type=int, dest='commandtype',
                    help='Execute command base on the num:0 mac-policy; 1 mac-rule;2 ip-policy;3 ip-rule;4 user-profile;5 security-object;6 walled-garden')

parser.add_argument('-l1', '--loop1', required=False, default=1, type=int, dest='loop1',
                    help='loop1-times')

parser.add_argument('-l2', '--loop2', required=False, default=1, type=int, dest='loop2',
                    help='loop2-times')

loginprompt = '[$#>?]'

def grep(file,exp): 
    f = open(file,'r') 
    lines = f.read().splitlines() 
    f.close(force=True)
    logs = []
    matchlinenum = 0 
    for i in lines: 
        if re.search(exp,i): 
            logs=logs.append(i) 
            matchlinenum = matchlinenum +1
    
    return logs

    