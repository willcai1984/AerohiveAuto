#!/usr/bin/python
# Filename: getinfo_ip.py
# Function: get interface info based on ip
# coding:utf-8
# Author: Will
# python getinfo_ip -d '10.155.32.254' -i 'eth0' -v 'ip'

import pexpect, sys, argparse, re, time

def _debug(msg='', is_debug=True):
    if msg and is_debug:
        print '%s Debug:' % time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime()),
        print msg

class AerohiveGet:
    def __init__(self, ip, user, passwd, prompt, timeout, interface, value, width, is_debug):
        # public
        self.ip = str(ip)
        self.user = user
        self.passwd = passwd
        self.prompt = prompt
        self.timeout = float(timeout)
        self.interface = interface
        self.value = value
        self.width = width
        self.is_debug = int(is_debug)
        # private
        self.spawn_child = ''

    def __del__(self):
        is_debug = self.is_debug
        try:
            self.spawn_child.close()
        except AttributeError:
            _debug('No spawn yet, please check pexpect generate spawn part', is_debug)
        _debug('Aerohive connect process done', is_debug)
    def Login(self):
        # public
        ip = self.ip
        user = self.user
        passwd = self.passwd
        prompt = self.prompt
        timeout = self.timeout
        is_debug = self.is_debug
        # private
        is_user = False
        is_passwd = False
        is_no = False
        is_prompt = False
        is_error = False
        # Login process start
        _debug('''.............Login process start....................''' , is_debug)
        spawn_child = pexpect.spawn('ssh %s@%s' % (user, ip))
        self.spawn_child = spawn_child
        index = spawn_child.expect([pexpect.TIMEOUT,
                       'Connection timed out',
                       'No route to host.*',
                       'Are you sure you want to continue connecting .*\?',
                       '[Pp]assword:',
                       'Welcome to Aerohive Product.*login:.*',
                       '[Nn]ame:',
                       prompt,
                       pexpect.EOF], timeout)
        if index == 0:
            print 'Login host timeout, please confirm you can reach the host'
            is_error = True
            _debug('''From 'Login command' mode jump to is_error''', is_debug)
        elif index == 1:
            print 'The mpc connect to the remote target timeout, please confirm the target is reachable.'
            is_error = True
            _debug('''From 'Login command' mode jump to is_error''', is_debug)
        elif index == 2:
            print 'The mpc has no route to the target, please confirm the route table and interface status'
            is_error = True
            _debug('''From 'Login command' mode jump to is_error''', is_debug)
        elif index == 3:
            _debug('The target is not in known host list, need send yes to confirm login', is_debug)
            spawn_child.sendline('yes')
            index = spawn_child.expect([pexpect.TIMEOUT, '[Pp]assword:', prompt], timeout)
            if index == 0:
                print 'Login host send yes to confirm login timeout, please confirm the host is reachable'
                is_error = True
                _debug('''From 'send yes to pass auth' mode jump to is_error''', is_debug)
            elif index == 1:
                _debug('Add host to known host list successfully, and meet password part', is_debug)
                is_passwd = True
                _debug('''From 'send yes to pass auth' mode jump to is_passwd''', is_debug)
            elif index == 2:
                _debug('Add host to known host list successfully, and meet prompt part', is_debug)
                is_prompt = True
                _debug('''From 'send yes to pass auth' mode jump to is_prompt''', is_debug)
        elif index == 4:
            is_passwd = True
            _debug('''From 'Login command' mode jump to is_passwd''', is_debug)
        elif index == 5:
            is_user = True
            _debug('''From 'Login command' mode jump to is_user''', is_debug)
        elif index == 6:
            is_user = True
            _debug('''From 'Login command' mode jump to is_user''', is_debug)
        elif index == 7:
            is_prompt = True
            _debug('''From 'Login command' mode jump to is_prompt''', is_debug)
        elif index == 8:
            is_error = True
            _debug('''From 'Login command' mode jump to is_error, meet Pexpect.EOF, please check your commands''', is_debug)
        else:
            print 'Not match any expect in step1 expect_list, please check'
            is_error = True
            _debug('''From 'Login command' mode jump to is_error''', is_debug)
        login_result = self._CommonLogin(is_user, is_passwd, is_no, is_prompt, is_error)
        _debug('''Login process done''', is_debug)             
        return login_result
    
    def ExecuteCMD(self):
        # public
        spawn_child = self.spawn_child
        prompt = self.prompt
        timeout = self.timeout
        interface = self.interface
        is_debug = self.is_debug
        execute_cmd = 'ifconfig %s' % interface
        _debug("Execute command is:%s" % execute_cmd, is_debug)
        spawn_child.sendline(execute_cmd)
        index = spawn_child.expect([pexpect.TIMEOUT, prompt], timeout)
        if index == 0:
            _debug('''Send command "%s" meet timeout''' % execute_cmd)
            _debug('Meet is_error, login failed', is_debug)
            print 'Connect failed.\nPexpect.before is %s.\nPexpect.after is %s.' % (spawn_child.before, spawn_child.after)
            raise ValueError, 'Connect process meet error'
        elif index == 1:
            _debug("Interface info is:%s" % spawn_child.before, is_debug)
            info = self._Getinfo(spawn_child.before)
            _debug("Get info is:%s" % info, is_debug)
            return info
           
    def Logout(self):
        # public
        spawn_child = self.spawn_child
        timeout = self.timeout
        is_debug = self.is_debug

        # logout process start      
        _debug('Logout process start', is_debug)
        _debug('.............logout process start.................', is_debug)
        spawn_child.sendcontrol('d')
        index = spawn_child.expect([pexpect.TIMEOUT, 'Connection to .* closed'], timeout)      
        if index == 0:
            raise ValueError, 'Logout failed, time out when sending ctrl+d'
        _debug('Logout successfully', is_debug) 
        return 1
        
    '''
    Define func CommonLogin
    '''
    def _CommonLogin(self, is_user, is_passwd, is_no, is_prompt, is_error):
        user = self.user
        passwd = self.passwd
        prompt = self.prompt
        is_debug = self.is_debug
        spawn_child = self.spawn_child
        timeout = self.timeout
        if is_user:
            _debug('Meet is_user, send user to confirm login', is_debug) 
            spawn_child.sendline(user)
            index = spawn_child.expect([pexpect.TIMEOUT, '[Pp]assword.*'], timeout)        
            if index == 0:
                print 'Send user to confirm login timeout, please confirm the host is alive'
                is_error = True
                _debug('''From is_user jump to is_error''', is_debug)
            elif index == 1:                  
                is_passwd = True
                _debug('''From is_user jump to is_passwd''', is_debug)
        if is_passwd:
            _debug('Meet is_password, send passwd to confirm login', is_debug)
            spawn_child.sendline(passwd)
            index = spawn_child.expect([pexpect.TIMEOUT, 'yes\|no>:.*', prompt, '\nlogin.*', '[Pp]assword.*'], timeout)
            if index == 0:
                print 'Send password to confirm login timeout, please confirm the host is alive'
                is_error = True
                _debug('''From is_passwd jump to is_error''', is_debug)
            elif index == 1:
                is_no = True
                _debug('''From is_passwd jump to is_no''', is_debug)
            elif index == 2:
                is_prompt = True
                _debug('''From is_passwd jump to is_prompt''', is_debug)                
            elif index == 3:
                print 'Meet is_user again, user or password maybe incorrect, please check'
                is_error = True
                _debug('''From is_passwd jump to is_error''', is_debug)
            elif index == 4:
                print 'Meet is_passwd again, password maybe incorrect, please check'
                is_error = True
                _debug('''From is_passwd jump to is_error''', is_debug)
        if is_no:
            _debug('Meet is_no(reset mode), send no to not use default config', is_debug)
            spawn_child.sendline('no')
            index = spawn_child.expect([pexpect.TIMEOUT, prompt], timeout)        
            if index == 0:
                print 'Send no to confirm login timeout, please confirm the host is alive'
                is_error = True
                _debug('''From is_no jump to is_error''', is_debug)
            elif index == 1:
                is_prompt = True
                _debug('''From is_no jump to is_prompt''', is_debug)
        if is_prompt:
            _debug('Meet is_prompt, login successfully', is_debug)
        if is_error:
            _debug('Meet is_error, login failed', is_debug)
            print 'Connect failed.\nPexpect.before is %s.\nPexpect.after is %s.' % (spawn_child.before, spawn_child.after)
            raise ValueError, 'Connect process meet error'
        return True
    
    def _Getinfo(self, f):
        value = self.value
        ip_reg_list = ["inet addr:(\d+\.\d+\.\d+\.\d+)",
                   "inet (\d+\.\d+\.\d+\.\d+)"]
        mac_reg_list = ["HWaddr (\w{2}:\w{2}:\w{2}:\w{2}:\w{2}:\w{2})",
                    "ether (\w{2}:\w{2}:\w{2}:\w{2}:\w{2}:\w{2})"]
        if value == 'ip':
            for ip_reg in ip_reg_list:
                ip = re.search(ip_reg, f)
                if ip:
                    return ip.group(1)
            return None
        elif value == 'mac':
            for mac_reg in mac_reg_list:
                mac = re.search(mac_reg, f)
                if mac:
                    orignal_mac = re.sub(':', '', mac.group(1).upper())
                    if self.width == 2:
                        return orignal_mac[0:2] + ":" + orignal_mac[2:4] + ":" + orignal_mac[4:6] + ":" + orignal_mac[6:8] + ":" + orignal_mac[8:10] + ":" + orignal_mac[10:12]
                    elif self.width == 4:
                        return orignal_mac[0:4] + ":" + orignal_mac[4:8] + ":" + orignal_mac[8:12]
            return None
    

parse = argparse.ArgumentParser(description='Connect to host and execute CMDs')
parse.add_argument('-d', '--destination', required=False, default='localhost', dest='des',
                    help='Target IP address')

parse.add_argument('-u', '--user', required=False, default='admin', dest='user',
                    help='Login user name')

parse.add_argument('-p', '--passwd', required=False, default='aerohive', dest='passwd',
                    help='Login Password')

parse.add_argument('-i', '--interface', required=False, default='eth0', dest='interface',
                    help='Login Password')

parse.add_argument('-m', '--prompt', required=False, default=']#|~#', dest='prompt',
                    help='Device prompt')

parse.add_argument('-t', '--timeout', required=False, default=20, type=int, dest='timeout',
                    help='Time out for every cmds response')

parse.add_argument('-v', '--value', required=False, default='ip', choices=['ip', 'mac'], dest='value',
                    help='The parameters you want to get')

parse.add_argument('-w', '--width', required=False, default=4, type=int, choices=[2, 4], dest='width',
                    help='The mac address format you want to get')

parse.add_argument('-debug', '--debug', required=False, default=False, action='store_true', dest='is_debug',
                    help='Enable debug mode')


def main():
    args = parse.parse_args() 
    des = args.des
    user = args.user
    passwd = args.passwd
    interface = args.interface
    prompt = args.prompt
    timeout = args.timeout
    value = args.value
    width = int(args.width)
    is_debug = args.is_debug
    getinfo = AerohiveGet(des, user, passwd, prompt, timeout, interface, value, width, is_debug)
    getinfo.Login()
    getinfo_value = getinfo.ExecuteCMD()
    if getinfo_value:
        print getinfo_value
    else:
        return False
    getinfo.Logout()
    return True
if __name__ == '__main__':
    try:
        execute_result = main()
        if execute_result:
            sys.exit(0)
        else:
            sys.exit(1)
    except Exception, e:
        print str(e)
        sys.exit(1)
