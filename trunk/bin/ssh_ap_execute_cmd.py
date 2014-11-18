#!/usr/bin/env python
# path: /auto_case/bin/
# Filename: ssh_ap_cmd.py
# Function: ssh tagert and execute cmds
# coding:utf-8
# Topo: LinuxPC-----L2sw-----(eth0)AP
# Author: Will

import argparse, sys, re, pexpect, time, os

parser = argparse.ArgumentParser(description='ssh server and execute cmds')

parser.add_argument('-d', '--deststa', required=True, default=None, dest='ipAddress',
                    help='Destination AP')

parser.add_argument('-u', '--user', required=True, default=None, dest='loginName',
                    help='User name')

parser.add_argument('-p', '--password', required=True, default=None, dest='loginPassword',
                    help='User password')

parser.add_argument('-c', '--command', required=True, default=0, type=int, dest='commandtype',
                    help='Execute command base on the num:0 mac-policy; 1 mac-rule;2 ip-policy;3 ip-rule;4 user-profile;5 security-object;6 walled-garden; 7 route-policy; 8 dnxp; 9 user-define')

parser.add_argument('-l1', '--loop1', required=False, default=1, type=int, dest='loop1',
                    help='loop1-times')

parser.add_argument('-l2', '--loop2', required=False, default=1, type=int, dest='loop2',
                    help='loop2-times')

parser.add_argument('-ec', '--executecommand', required=False, default=0, type=str, dest='executecommand',
                    help='execute user define command')

parser.add_argument('-pa', '--parameters', required=False, default=0, type=str, dest='parameters',
                    help='user define command parameters')

loginprompt = '[$#>?]'

#Define Function for sleep
def sleep (mytime=1):
    time.sleep(mytime)


#Define Function for clear ssh known file

def clear_ssh_file ():
    commandrm = 'rm /root/.ssh/known_hosts'
    os.system(commandrm)
        
#Define Function for SSH target AP

def ssh_execute_command (user, ip, password, cmdtype, loop1, loop2, cmduser, cmdpar):
    commandssh = 'ssh %s@%s' % (user, ip)
    sshcmd = pexpect.spawn(commandssh)
    i = sshcmd.expect([pexpect.TIMEOUT, 'continue connecting', 'password'], timeout=20)
    print sshcmd.before, sshcmd.after
    if i == 0:
        print 'ERROR!'
        print 'TimeOut when ssh the target'
        print sshcmd.before, sshcmd.after
        return 'fail'
    if i == 1:
        sshcmd.sendline('yes')
        print 'Confirm login, send yes'
        i = sshcmd.expect([pexpect.TIMEOUT, 'password'], timeout=10)
        print sshcmd.before
        if i == 0:
            print 'ERROR!'
            print "TimeOut when send cmd 'yes'"
            print sshcmd.before, sshcmd.after
            return 'fail'
    sshcmd.sendline(password)
    print 'Get password, send password'
    i = sshcmd.expect([pexpect.TIMEOUT, 'Aerohive Networks'], timeout=10)
    if i == 0:
        print 'ERROR!'
        print 'TimeOut when login the AP'
        print sshcmd.before, sshcmd.after
        return 'fail'
    if i == 1:
        print 'Log successfully!'
        print 'Executing configure now'
#Execute Configure script
        cmdtype = int(cmdtype)
        loop1 = int(loop1)
        loop2 = int(loop2)
        print 'cmdtype = %d' % (cmdtype)
        print 'loop1 is %d' % (loop1)
        print 'loop2 is %d' % (loop2)
####Execute MAC-Policy configure script
#######Mac-policy:32policies  
        if cmdtype == 0:
            for a in range(1, loop1 + 1):
                cmdexecute = 'mac-policy %d' % (a)
                sshcmd.sendline(cmdexecute)
                print cmdexecute
                i = sshcmd.expect([pexpect.TIMEOUT, loginprompt], timeout=30)
                if i == 0:
                    print 'ERROR!'
                    print 'Timeout when execute configure script'
                    print sshcmd.before, sshcmd.after
                    return 'fail'
                    break
                if i == 1:
                    sleep(0.2)       

#######Mac-policy:32rules, loop1 is policy name  
        if cmdtype == 1:
            for a in range(1, loop2 + 1):
                cmdexecute = 'mac-policy %d id %d from 0000:0%03d:0%03d action permit' % (loop1, a, loop1, a)
                sshcmd.sendline(cmdexecute)
                print cmdexecute
                i = sshcmd.expect([pexpect.TIMEOUT, loginprompt], timeout=30)
                if i == 0:
                    print 'ERROR!'
                    print 'Timeout when execute configure script'
                    print sshcmd.before, sshcmd.after
                    return 'fail'
                    break
                if i == 1:
                    sleep(0.2) 
        
#######Mac-policy:32policy/32rule        
#        if cmdtype == 0:
#            for a in range(1, loop1):
#                cmdexecute = 'mac-policy %d' % (a)
#                sshcmd.sendline(cmdexecute)
#                print cmdexecute
#                i = sshcmd.expect([pexpect.TIMEOUT, loginprompt], timeout=30)
#                if i == 0:
#                    print 'ERROR!'
#                    print 'Timeout when execute configure script'
#                    print sshcmd.before, sshcmd.after
#                    return 'fail'
#                    break
#                if i == 1:
#                    for b in range(1, 33):
#                        if b < 10000:
#                            cmdexecute = 'mac-policy %d id %d from 0000:0%03d:0%03d action permit' % (a, b, a, b)
#                            sshcmd.sendline(cmdexecute)
#                            print cmdexecute
#                            i = sshcmd.expect([pexpect.TIMEOUT, loginprompt], timeout=30)
#                            if i == 0:
#                                print 'ERROR!'
#                                print 'Timeout when execute configure script'
#                                print sshcmd.before, sshcmd.after
#                                return 'fail'
#                            break
#                            if i == 1:
#                                if b < 32:
#                                    sleep(0)
#                                elif b < 48:
#                                    sleep(0.2)
#                                elif b < 65:
#                                    sleep(0.3)
#                                else:
#                                    sleep(1)        
#                                
#                        else:
#                            print 'Mac-policy rules is bigger than 999, AP cannot process'
#                if a < 9:
#                    sleep(0.1)
#                elif a < 18:
#                    sleep(0.2)
#                elif a < 27:
#                    sleep(0.3)
#                else:
#                    sleep(0.5)   

####Execute IP-Policy configure script
#######IP-policy:32policies 
        if cmdtype == 2:
            for a in range(1, loop1 + 1):
                cmdexecute = 'ip-policy %d' % (a)
                sshcmd.sendline(cmdexecute)
                print cmdexecute
                i = sshcmd.expect([pexpect.TIMEOUT, loginprompt], timeout=30)
                if i == 0:
                    print 'ERROR!'
                    print 'Timeout when execute configure script'
                    print sshcmd.before, sshcmd.after
                    return 'fail'
                    break
                if i == 1:
                    sleep(0.2)

#######IP-policy:32rule, loop1 is policy name
        if cmdtype == 3:
            for a in range(1, loop2 + 1):
                cmdexecute = 'ip-policy %d id %d from 10.10.%d.%d action permit' % (loop1, a, loop1, a)
                sshcmd.sendline(cmdexecute)
                print cmdexecute
                i = sshcmd.expect([pexpect.TIMEOUT, loginprompt], timeout=30)
                if i == 0:
                    print 'ERROR!'
                    print 'Timeout when execute configure script'
                    print sshcmd.before, sshcmd.after
                    return 'fail'
                    break
                if i == 1:
                    sleep(0.2)

#######IP-policy:32policy/64rule               
#        if cmdtype == 1:
#            for a in range(1, loop1):
#                cmdexecute = 'ip-policy %d' % (a)
#                sshcmd.sendline(cmdexecute)
#                print cmdexecute
#                i = sshcmd.expect([pexpect.TIMEOUT, loginprompt], timeout=30)
#                if i == 0:
#                    print 'ERROR!'
#                    print 'Timeout when execute configure script'
#                    print sshcmd.before, sshcmd.after
#                    return 'fail'
#                    break
#                if i == 1:
#                    for b in range(1, 65):
#                        if b < 255:
#                            cmdexecute = 'ip-policy %d id %d from 10.10.%d.%d action permit' % (a, b, a, b)
#                            sshcmd.sendline(cmdexecute)
#                            print cmdexecute
#                            i = sshcmd.expect([pexpect.TIMEOUT, loginprompt], timeout=30)
#                            if i == 0:
#                                print 'ERROR!'
#                                print 'Timeout when execute configure script'
#                                print sshcmd.before, sshcmd.after
#                                return 'fail'
#                                break
#                            if i == 1:
#                                if b < 32:
#                                    sleep(0)
#                                elif b < 48:
#                                    sleep(0.2)
#                                elif b < 65:
#                                    sleep(0.3)
#                                else:
#                                    sleep(1) 
#                        else:
#                            print 'IP-policy rules is bigger than 256, AP cannot process'
#                if a < 9:
#                    sleep(0)
#                elif a < 18:
#                    sleep(0.2)
#                elif a < 27:
#                    sleep(0.3)
#                else:
#                    sleep(0.5)
                    
                                      
####Execute User-profile configure script                                
        if cmdtype == 4:
            for a in range(1, loop1 + 1):
                cmdexecute = 'user-profile  %d' % (a)
                sshcmd.sendline(cmdexecute)
                print cmdexecute
                i = sshcmd.expect([pexpect.TIMEOUT, loginprompt], timeout=30)
                if i == 0:
                    print 'ERROR!'
                    print 'Timeout when execute configure script'
                    print sshcmd.before, sshcmd.after
                    return 'fail'
                    break
                if i == 1:
                    continue

####Execute security-object configure script
        if cmdtype == 5:
            for a in range(1, loop1 + 1):
                cmdexecute = 'security-object %d' % (a)
                sshcmd.sendline(cmdexecute)
                print cmdexecute
                i = sshcmd.expect([pexpect.TIMEOUT, loginprompt], timeout=30)
                if i == 0:
                    print 'ERROR!'
                    print 'Timeout when execute configure script'
                    print sshcmd.before, sshcmd.after
                    return 'fail'
                    break
                if i == 1:             
                    sleep(0.2)
                    
####Execute walled-garden configure script               
        if cmdtype == 6:
            for a in range(1, loop2 + 1):
                cmdexecute = 'security-object %d walled-garden hostname www.test%d.com' % (loop1, a)
                sshcmd.sendline(cmdexecute)
                print cmdexecute
                i = sshcmd.expect([pexpect.TIMEOUT, loginprompt], timeout=30)
                if i == 0:
                    print 'ERROR!'
                    print 'Timeout when execute configure script'
                    print sshcmd.before, sshcmd.after
                    return 'fail'
                    break
                if i == 1:
                    sleep(0.2)
                    
####Execute route configure script               
        if cmdtype == 7:
            for a in range(1, loop1 + 1):
                cmdexecute = 'route 0000:0000:0%02d outgoing-interface eth1 next-hop aa-aa-aa-aa-aa-aa' % a
                sshcmd.sendline(cmdexecute)
                print cmdexecute
                i = sshcmd.expect([pexpect.TIMEOUT, loginprompt], timeout=30)
                if i == 0:
                    print 'ERROR!'
                    print 'Timeout when execute configure script'
                    print sshcmd.before, sshcmd.after
                    return 'fail'
                    break
                if i == 1:
                    sleep(0.2)
    
####Execute dnxp configure script               
        if cmdtype == 8:
            for a in range(1, loop1 + 1):
                cmdexecute = 'mobility-policy dnxp%d dnxp' % a
                sshcmd.sendline(cmdexecute)
                print cmdexecute
                i = sshcmd.expect([pexpect.TIMEOUT, loginprompt], timeout=30)
                if i == 0:
                    print 'ERROR!'
                    print 'Timeout when execute configure script'
                    print sshcmd.before, sshcmd.after
                    return 'fail'
                    break
                if i == 1:
                    sleep(0.2)

####Execute user define commands
        if cmdtype == 9:
            for a in range(1, loop1 + 1):
                cmdpar.repalce('l1', 'a')
                cmdexecute = cmduser % cmdpar
                sshcmd.sendline(cmdexecute)
                print cmdexecute
                i = sshcmd.expect([pexpect.TIMEOUT, loginprompt], timeout=30)
                if i == 0:
                    print 'ERROR!'
                    print 'Timeout when execute configure script'
                    print sshcmd.before, sshcmd.after
                    return 'fail'
                    break
                if i == 1:
                    sleep(0.2)
                    
                    
    print 'The loop is over'
    return 'success'
#Execute Configure script over

#Close the connection(close the child)
    sshcmd.close(force=True)
    print 'The script status is %s' % (sshcmd)


args = parser.parse_args()
ip = args.ipAddress
user = args.loginName
password = args.loginPassword
cmdtype = args.commandtype
loop1 = args.loop1
loop2 = args.loop2
cmduser = args.executecommand
cmdpar = args.parameters

RunResult = ssh_execute_command (user, ip, password, cmdtype, loop1, loop2, cmduser, cmdpar)
print 'The script run result is %s' % (RunResult)

if (RunResult == 'fail'):
  print 'Script executing error, system return 1 '
  sys.exit(1)
else:
  print 'Script executing success, system return 0'
  sys.exit(0)
