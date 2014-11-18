#!/usr/bin/python
# Filename: get_ixia_pkt.py
# Function: get frame send 
# -*- coding: UTF-8 -*-
# Author: W1ll
# Example command:python get_ixia_pkt.py -f test.log -r 1.2.2/python test.py -f test.log -t 1.2.3
import re, argparse, sys

def debug(mesage, is_debug=True):
    if mesage and is_debug:
        print 'DEBUG',
        print mesage

def get_pkt_num(file_path, tx_reg='', rx_reg='', mode='frames', size=128, is_debug=False):
    size = int(size)
    with open (file_path) as file_open:
        file_list = file_open.readlines()
    for line in file_list:
        if tx_reg:
            debug('tx mode get info', is_debug)
            tx_num_reg = re.search('tx.port.%s=(\d+)' % tx_reg, line)
            if tx_num_reg:
                tx_num = tx_num_reg.group(1)
                debug('Get tx num successfully, the num is %s' % tx_num, is_debug)
                if mode == 'frames':
                    return tx_num
                elif mode == 'octets':
                    return int(tx_num) * size
        elif rx_reg:
            debug('rx mode get info', is_debug)
            rx_num_reg = re.search('rx.port.%s=(\d+)' % rx_reg, line)
            if rx_num_reg:
                rx_num = rx_num_reg.group(1)
                debug('Get rx num successfully, the num is %s' % rx_num, is_debug)
                if mode == 'frames':
                    return rx_num
                elif mode == 'octets':
                    return int(rx_num) * size            
    return None

parse = argparse.ArgumentParser(description='Get info from IXIA log file')
parse.add_argument('-f', '--file', required=True, dest='file_path',
                    help='file path')

parse.add_argument('-t', '--transmit', required=False, default='', dest='tx',
                    help='transmit port, format is 1.2.1[.x]')

parse.add_argument('-r', '--receive', required=False, default='', dest='rx',
                    help='receive port, format is 1.2.1[.x]')

parse.add_argument('-tp', '--transmitparameter', required=False, default='framesSent', dest='t_p',
                    help='framesSent framesReceived userDefinedStat2')

parse.add_argument('-rp', '--receiveparameter', required=False, default='userDefinedStat2', dest='r_p',
                    help='framesSent framesReceived userDefinedStat2')

parse.add_argument('-m', '--mode', required=False, default='frames', choices=['frames', 'octets'], dest='mode',
                    help='stats mode')

parse.add_argument('-s', '--size', required=False, default=128, type=int, dest='size',
                    help='pkt size')

parse.add_argument('-debug', '--debug', required=False, default=False, action='store_true', dest='is_debug',
                    help='enable debug mode')

def main():
    args = parse.parse_args() 
    file_path = args.file_path
    tx = args.tx
    rx = args.rx
    t_p = args.t_p
    r_p = args.r_p
    mode = args.mode
    size = args.size
    is_debug = args.is_debug
    tx_reg = ''
    rx_reg = ''
    if tx:
        tx_reg = '.'.join(tx.split('/')) + '.*' + t_p
        debug('tx_reg port is %s' % tx_reg, is_debug)
    if rx:
        rx_reg = '.'.join(rx.split('/')) + '.*' + r_p
        debug('rx_reg port is %s' % rx_reg, is_debug)
    pkt_num = get_pkt_num(file_path, tx_reg, rx_reg, mode, size, is_debug)
    return pkt_num

if __name__ == '__main__':
    try:
        pkt_num = main()
        print pkt_num
        sys.exit(0)
    except Exception, e:
        sys.exit(1)
        
