__author__ = 'hshao'
#!/usr/bin/python
# Filename: parseJson.py
# Function: get value from json text
# coding:utf-8
# Author: Well
# Example command: parseJson.py -d -f /logs/log20140220-0977/hshao_test_cloud_curl.xml_tc1/get_token_login.log -k access_token

import sys
import argparse
import types
import time
import os
import json
import string

def sleep(secTime = 1):
    time.sleep(secTime)

def debug(mesage, is_debug=True):
    if mesage and is_debug:
        print '%s DEBUG' % time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime()),
        print mesage

def main():
    args = parse.parse_args()
    is_debug = args.is_debug
    logFilePath = args.logFilePath
    keyName = args.keyName
    parse_result = (0,)
    debug("start parse Json from logFile...", is_debug)

    if logFilePath is None:
        debug("Json file path is None", is_debug)
        debug(msg)
        return parse_result

    if keyName is None:
        debug("key name is None", is_debug)
        return parse_result

    if os.path.exists(logFilePath) == False:
        debug("Json file path is not exists", is_debug)
        return parse_result

    keyNameList = keyName.split(":")

    try:
        f = file(logFilePath)
        s = json.load(f)
        ret_val = ''
        for k in keyNameList:
            if ret_val == '':
                ret_val = s[k]
            else:
                if type(ret_val) is types.ListType and unicode(str(k)).isdecimal():
                    ret_val = ret_val[string.atoi(k)]
                elif type(ret_val) is types.ListType and unicode(str(k)).isdecimal() == False:
                    debug('keyName type is not int, keyName=>' + string(k))
                elif type(ret_val) is types.DictType:
                    ret_val = ret_val[k]
                else:
                    debug('ret_val type is String or int, ret_val => ' + string(ret_val))
                    ret_val = None
                    break
        parse_result = (1,ret_val)
        #print(parse_result)
    except Exception, e:
        debug(str(e),is_debug)
    finally:
        f.close()

    return parse_result


parse = argparse.ArgumentParser(description='parse json from log file')
parse.add_argument('-f', '--file', required=True, default=None, dest='logFilePath',
                    help='log file path')

parse.add_argument('-k', '--key', required=True, default=None, dest='keyName',
                    help='need key name')

parse.add_argument('-d', '--debug', required=False, default=False, action='store_true', dest='is_debug',
                    help='enable debug mode')

if __name__ == '__main__':
    console_result = main()
    if console_result[0] == 1:
        print console_result[1]
        sys.exit(0)
    else:
        print None
        sys.exit(1)

