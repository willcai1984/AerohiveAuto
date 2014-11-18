#!/usr/bin/env python
# path: /auto_case/bin/
# Filename: loopsendpkt.py
# Function: loop send pkt(pkt or hping) in order
# coding:utf-8
# Topo: LinuxPC
# Author: Well

import argparse, sys, os

parser = argparse.ArgumentParser(description='Search the file and print the match line info')

parser.add_argument('-d', '--dstip', required=True, default=None, dest='dstip',
                    help='Destination IP')

parser.add_argument('-s', '--srcip', required=True, default=None, dest='srcip',
                    help='Source IP')

parser.add_argument('-I', '--interface', required=True, default=None, dest='interface',
                    help='Outgoing interface')

parser.add_argument('-l', '--loop', required=False, default=1, type=int, dest='loop',
                    help='loop-times')

loginprompt = '[$#>?]'

#Define function for execute loop
def exec_loop(interface, dstip, srcip, loop):
    loop = int(loop)
    for i in range(1, loop + 1):
        if i < 100: 
            command = 'pkt -i %s -d %s -m %s -N ff:ff:ff:ff:ff:ff -M 00:00:00:00:00:%02d -p arpreq' % (interface, dstip, srcip, i)
        elif i < 10000:
            a = i / 100
            b = i - a * 100
            command = 'pkt -i %s -d %s -m %s -N ff:ff:ff:ff:ff:ff -M 00:00:00:00:%02d:%02d -p arpreq' % (interface, dstip, srcip, a, b)
        else:
            print 'The loop num is above 10000, AP cannot process'
        os.system(command)
        print command

    print 'The loop is over'
    return 'success'

args = parser.parse_args()
interface = args.interface
dstip = args.dstip
srcip = args.srcip
loop = args.loop

exeresult = exec_loop(interface, dstip, srcip, loop)
if (exeresult == 'fail'):
  print 'Script executing error, system return 1 '
  sys.exit(1)
else:
  print 'Script executing success, system return 0'
  sys.exit(0)
        
