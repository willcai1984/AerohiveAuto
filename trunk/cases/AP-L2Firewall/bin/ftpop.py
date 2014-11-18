#!/usr/bin/python

import argparse, ftplib, time, os

parser = argparse.ArgumentParser(description='connect to ftp server and keep alive')

parser.add_argument('-d', '--debug', required=False, default=False, dest='debug', action='store_true',
                    help='debug msg')

parser.add_argument('-u', '--user_name', required=True, dest='user_name',
                    help='user name')

parser.add_argument('-p', '--password', required=True, dest='password',
                    help='password')

parser.add_argument('-s', '--ftp_server', required=True, dest='ftp_server',
                    help='ftp server to connect')

parser.add_argument('-lf', '--log_file', required=True, dest='log_file',
                    help='the log file on mc')

parser.add_argument('-ff', '--flag_file', required=True, dest='flag_file',
                    help='the flag file on mc which will be checked')

def debug(msg, debug=True):
    if args.debug:
        if msg and debug:
            print 'DEBUG',
        print msg

args = parser.parse_args()

f = file(args.log_file,'w')

if __name__ == '__main__':

    debug('user name is: %s' % args.user_name)
    debug('password is: %s' % args.password)
    debug('ftp server is: %s' % args.ftp_server)
    debug('log file is: %s' % args.log_file)
    debug('flag file is: %s' % args.flag_file)


    ftp = ftplib.FTP(args.ftp_server, timeout = 10)
    ftp.login(args.user_name, args.password)
    f.write('connect the server!\n')
    while True:
       value = os.path.isfile(args.flag_file)
       if value:
           ftp.pwd()
           f.write('flag file appear,break %s\n' % ftp.pwd())
           break
       else:
           try:
               ftp.pwd()
           except:
               f.write('fail connection\n')
           f.write('corrent directory %s\n' % ftp.pwd())
           f.write('no flag file,continue\n')
           time.sleep(2)
f.close()