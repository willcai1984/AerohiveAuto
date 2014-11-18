#!/usr/bin/env python
# path: /auto_case/bin/
# Filename: remove_screen.py
# Function: remove all matched screen via string you input
# coding:utf-8
# Topo: LinuxPC
# Author: Will

import argparse, sys, re, os

parse = argparse.ArgumentParser(description='Search the file and print the match line info')

parse.add_argument('-p', '--parameters', required=True, default=None, dest='para',
                    help='Key parameters to kill the screen')

def main():
    args = parse.parse_args() 
    para = args.para
    ###get the screen_pid_list
    screen_list_open = os.popen('screen -list|grep -v Attached| grep %s' % para)
    screen_list_read = screen_list_open.read()
    screen_pid_list = re.findall('\s(\d+)\.', screen_list_read)
    ###kill the alive pid
    if screen_pid_list:
        screen_pid_string = ' '.join(screen_pid_list)
        os.system('kill -9 %s' % screen_pid_string)
        ###reomve dead screen
        os.system('screen -wipe')
    else:
        return None
if __name__ == '__main__':
    remove_result = main()
