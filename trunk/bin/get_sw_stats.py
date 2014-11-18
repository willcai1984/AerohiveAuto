#!/usr/bin/python
# Filename: get_sw_stats.py
# Function: get frame send 
# -*- coding: UTF-8 -*-
# Author: Well
# Example command:python get_ixia_pkt.py -f test.log -p eth1/21 -s 'io'
import re, argparse, sys

def debug(mesage, is_debug=True):
    if mesage and is_debug:
        print 'DEBUG',
        print mesage

def get_stats(file_path, portname, stats, is_debug=False):
    with open (file_path) as file_open:
        file_read = file_open.read()
        port_stats = re.findall('%s +\d+ +\d+ +\d+ +\d+' % portname, file_read)
        debug("The port status is as below %s" % str(port_stats), is_debug)
    if len(port_stats) == 2:
        debug('Get port stats successfully', is_debug)
        #'io','iu','im','ib','oo','ou','om','ob'
        in_status = re.findall(' (\d+)', port_stats[0])
        out_status = re.findall(' (\d+)', port_stats[1])
        if stats == 'io':
            return in_status[0]
        elif stats == 'iu':
            return in_status[1]
        elif stats == 'im':
            return in_status[2]
        elif stats == 'ib':
            return in_status[3]
        elif stats == 'oo':
            return out_status[0]
        elif stats == 'ou':
            return out_status[1]
        elif stats == 'om':
            return out_status[2]
        elif stats == 'ob':
            return out_status[2]
    else:
        debug("The input port stats log is not match the aerohive's format",is_debug)
        return None

parse = argparse.ArgumentParser(description='Get info from IXIA log file')
parse.add_argument('-f', '--file', required=True, dest='file_path',
                    help='file path')

parse.add_argument('-p', '--portname', required=True, dest='portname',
                    help='in octets')

parse.add_argument('-s', '--stats', required=True, default='io', choices=['io', 'iu', 'im', 'ib', 'oo', 'ou', 'om', 'ob'], dest='stats',
                    help='the stats you want to get')

parse.add_argument('-debug', '--debug', required=False, default=False, action='store_true', dest='is_debug',
                    help='enable debug mode')

def main():
    args = parse.parse_args() 
    file_path = args.file_path
    portname = args.portname
    stats = args.stats
    is_debug = args.is_debug
    port_stats = get_stats(file_path, portname, stats, is_debug)
    return port_stats

if __name__ == '__main__':
    try:
        port_stats = main()
        print port_stats
        sys.exit(0)
    except Exception, e:
        sys.exit(1)
        
