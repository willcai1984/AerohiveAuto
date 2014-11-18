#!/usr/bin/env python
import pexpect
import argparse, sys, re
from datetime import datetime, timedelta
from time import mktime

parser = argparse.ArgumentParser(description = 'ssh server')

parser.add_argument('-d', '--deststa', required=True, default=None, dest='ipAddress',
                    help='Destination station')

parser.add_argument('-u', '--user', required=True, default=None, dest='loginName',
                    help='User name')

parser.add_argument('-p', '--password', required=True, default=None, dest='loginPassword',
                    help='User password')

parser.add_argument('-t', '--port', required=True, default=None, dest='sshPort',
                    help='ssh special port')

parser.add_argument('-c', '--command', required=True, default=None, dest='sshCommand',
                    help='ssh command')
  
  
def ssh_command (user, host, password, port, command): 
  cmd = 'ssh ' + user + '@' + host + ' -p ' + port  
  child = pexpect.spawn(cmd)  
  index1 = child.expect(["(?i)Are you sure you want to continue connecting", "(?i)password", "(?i)Unknown host", pexpect.EOF, pexpect.TIMEOUT], timeout=5)
  
  if (index1 == 0 ):
    child.sendline('yes')
    index2 = child.expect(["(?i)password", pexpect.EOF, pexpect.TIMEOUT], timeout=5)
    
    if (index2 == 0):
      child.sendline(password)
      index3 = child.expect(["(?i)ah-\d+", pexpect.EOF, pexpect.TIMEOUT], timeout=5)
      
      if (index3 == 0):
          child.sendline(command)
          print 'ssh login successfully'   
          return child
    
      if (index3 != 0):
          print "ssh login failed"
          print child.before, child.after
          return 'fail'
    
    if (index2 != 0):
      print "ssh login failed"
      print child.before, child.after
      return 'fail'
  
  elif (index1 == 1):
    child.sendline(password)
    index3 = child.expect(["(?i)ah-\d+", pexpect.EOF, pexpect.TIMEOUT], timeout=5)
    
    if (index3 == 0):
      child.sendline(command)
      print 'ssh login successfully'
      return child
    
    if (index3 != 0):
      print "ssh login failed"
      print child.before, child.after
      return 'fail'
  
  else:
      print "ssh login failed"
      print child.before, child.after
      return 'fail'
  
args = parser.parse_args()
host = args.ipAddress
user = args.loginName
password = args.loginPassword
port = args.sshPort
command = args.sshCommand
child = ssh_command (user, host, password, port, command)
if (child == 'fail'):
  sys.exit(1)
else:    
  child.expect("(?i)ah-\d+")
  print child.before
  sys.exit(0)