#!/usr/bin/python
# Filename: ssh_execute_cli.py
# Function: ssh target execute cli
# coding:utf-8
# Author: Will
# Example command:ssh_execute_cli.py -d ip -u user -p password -m prompt -o timeout -l logdir -z logfile -v "show run" -v "show version"
import pexpect, sys, argparse, re, time

def sleep (mytime=1):
    time.sleep(mytime)

def debug(mesage, is_debug=True):
    if mesage and is_debug:
        print '%s DEBUG' % time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime()),
        print mesage

def str_to_list(string, is_debug=True):
    input_list=string.split(',')
    str_list=[]
    for input_member in input_list:
        index1=re.search(r'[\D+]',input_member)
        index2=re.search(r'^\d+-\d+$',input_member)
        ###when index1 is None, match format'x'
        if index1==None:
            str_list.append(int(input_member))
        ###If index1 is Not None(True), need check index2, index2 should be True, match 'x-x' 
        elif index1 and index2:
            input_member_range_list=re.findall(r'\d+',input_member)
            ###need switch to int() before calculate
            input_member_range=int(input_member_range_list[1])-int(input_member_range_list[0])
            ###Judge if input_range is more than 0
            ######if equal to 0 add the member to the list 
            if input_member_range == 0:
                str_list.append(int(input_member_range_list[0]))
            ######if the range is >0 add the member in order
            elif input_member_range > 0:
                ###range() cannot cover the last one, so you need add 1 for the last
                for str_member in range(int(input_member_range_list[0]),int(input_member_range_list[1])+1):
                    ###primary mode is int, do not need switch 
                    str_list.append(int(str_member))
            else:
                print '''This parameter %s is not match format, the first member should less than the second ''' % input_member
                return None
        else:
            print '''This parameter %s is not match format, please enter correct format such as 'x,x,x' or 'x-x,x-x,x' ''' % input_member
            return None
    return str_list


def generate_cli_list(cli_list, prompt, timeout, passwd='', shellpasswd='', bootpasswd=''):
    cli_expect_timeout_list = [] 
    ctrl_index_list = []
    ctrl_index = 0
    reboot_timeout = 300
    save_img_timeout = 1200
    boot_timeout = 30
    for cli in cli_list:
        log_regex = re.compile('^show log.*')
        reset_config_regex = re.compile('^reset config$')
        reset_boot_regex = re.compile('^reset config bootstrap$')
        reboot_regex = re.compile('^reboot$')
        save_config_regex = re.compile('^save config tftp:.* (current|bootstrap)')
        # ##v9 add img for accurate match
        save_image_regex = re.compile('^save image tftp:.*img$')
        # ##v9 add support save image reboot cases
        save_image_reboot_regex = re.compile('^save image tftp:.*now$')
        shell_regex = re.compile('^_shell$')
        exit_regex = re.compile('^exit$')
        enble_regex = re.compile('^enable$')
        country_regex = re.compile('^boot-param country-code.*')
        ctrl_regex = re.compile('ctrl-.*')
        # ##v12 add ^reset$ for logout bootload
        reset_regex = re.compile('^reset$')
        # ##v12 add quit for quit login status
        quit_regex = re.compile('^quit$')
        if log_regex.search(cli):
            cli_expect_timeout_list.append((cli, '\w+.*', timeout))
            cli_expect_timeout_list.append(('', prompt, timeout))
            ctrl_index = ctrl_index + 2
        elif reset_boot_regex.search(cli):
            cli_expect_timeout_list.append((cli, r'bootstrap configuration.*', timeout))
            cli_expect_timeout_list.append(('y', prompt, reboot_timeout))
            ctrl_index = ctrl_index + 2
        elif reset_config_regex.search(cli):
            cli_expect_timeout_list.append((cli, r'bootstrap configuration.*', timeout))
            cli_expect_timeout_list.append(('y', prompt, timeout))
            cli_expect_timeout_list.append(('', 'login:', reboot_timeout))
            ctrl_index = ctrl_index + 3
        elif reboot_regex.search(cli):
            # ##v14 add support bootload
            if bootpasswd:
                cli_expect_timeout_list.append((cli, 'Do you really want to reboot.*', timeout))
                cli_expect_timeout_list.append(('y', prompt, timeout))
                cli_expect_timeout_list.append(('', 'Hit.*to stop.*autoboot.*2', boot_timeout))
                cli_expect_timeout_list.append(('', '[Pp]assword:', timeout))
                cli_expect_timeout_list.append((bootpasswd, '.*>', timeout))
                ctrl_index = ctrl_index + 5
            else:
                cli_expect_timeout_list.append((cli, 'Do you really want to reboot.*', timeout))
                cli_expect_timeout_list.append(('y', prompt, timeout))
                cli_expect_timeout_list.append(('', 'login:', reboot_timeout))
                ctrl_index = ctrl_index + 3               
        elif save_config_regex.search(cli):
            cli_expect_timeout_list.append((cli, r'configuration.*', timeout))
            cli_expect_timeout_list.append(('y', prompt, timeout))
            ctrl_index = ctrl_index + 2
        elif save_image_regex.search(cli):
            cli_expect_timeout_list.append((cli, r'update image.*', timeout))
            cli_expect_timeout_list.append(('y', prompt, save_img_timeout))
            ctrl_index = ctrl_index + 2
        # ##v9 add support save image and reboot
        elif save_image_reboot_regex.search(cli):
            cli_expect_timeout_list.append((cli, r'update image.*', timeout))
            cli_expect_timeout_list.append(('y', prompt, save_img_timeout))
            cli_expect_timeout_list.append(('', 'login:', reboot_timeout))
            ctrl_index = ctrl_index + 3
        elif shell_regex.search(cli):
            cli_expect_timeout_list.append((cli, '[Pp]assword:', timeout))
            cli_expect_timeout_list.append((shellpasswd, prompt, timeout))
            ctrl_index = ctrl_index + 2
        elif exit_regex.search(cli):
            cli_expect_timeout_list.append((cli, prompt, timeout))                
            ctrl_index = ctrl_index + 1          
        elif enble_regex.search(cli):
            cli_expect_timeout_list.append((cli, '[Pp]assword', timeout))
            cli_expect_timeout_list.append((passwd, prompt, timeout))
            ctrl_index = ctrl_index + 1               
        elif country_regex.search(cli):
            cli_expect_timeout_list.append((cli, 'To apply radio setting.*it now\?', timeout))
            cli_expect_timeout_list.append(('y', prompt, timeout))
            cli_expect_timeout_list.append(('', 'login:', reboot_timeout))
            ctrl_index = ctrl_index + 3    
        elif ctrl_regex.search(cli):
            cli_expect_timeout_list.append((cli, prompt, timeout))
            ctrl_index_list.append(ctrl_index)
            ctrl_index = ctrl_index + 1
        # v12 reset for bootload only
        elif reset_regex.search(cli):
            cli_expect_timeout_list.append((cli, 'login:', reboot_timeout))
            ctrl_index = ctrl_index + 1  
        # v12 add quit for quit login status
        elif quit_regex.search(cli):
            cli_expect_timeout_list.append((cli, 'login:', timeout))
            ctrl_index = ctrl_index + 1  
        else:
            cli_expect_timeout_list.append((cli, prompt, timeout))
            ctrl_index = ctrl_index + 1
    return cli_expect_timeout_list, ctrl_index_list


def ssh_login(ip,user,passwd,port,prompt,log_file_path,log_file_open=[],login_timeout=10,is_debug=True):
    ssh_login_command = 'ssh %s@%s -p %s' % (user, ip, port)
    debug('''SSH login command is "%s"''' % ssh_login_command, is_debug)
    debug('Step1 send ssh command to login host', is_debug)
    ssh_login_result = pexpect.spawn(ssh_login_command)
    if log_file_path == './stdout':
        ssh_login_result.logfile_read = sys.stdout
    else:
        ssh_login_result.logfile_read = log_file_open
    index = ssh_login_result.expect([pexpect.TIMEOUT, 'Are you sure you want to continue connecting .*\?', '[Pp]assword', prompt], timeout=login_timeout)
    if index == 0:
        print 'SSH host timeout, please confirm you can reach the host'
        print 'before is %s' % ssh_login_result.before
        print 'after is %s' % ssh_login_result.after
        ssh_login_result.close(force=True)
        return None
    elif index == 1:
        debug('The host is not in known host list, need send yes to confirm login', is_debug)
        ssh_login_result.sendline('yes')
        index = ssh_login_result.expect([pexpect.TIMEOUT, '[Pp]assword:'], timeout=login_timeout)
        if index == 0:
            print '''TimeOut when send 'yes' confirm authenticity to login'''
            print 'before is %s' % ssh_login_result.before
            print 'after is %s' % ssh_login_result.after
            ssh_login_result.close(force=True)
            return None
        elif index == 1:
            debug('Add host to known host list successfully, and meet password part', is_debug)
    elif index == 2:
        debug('Add host to known host list successfully, and meet password part', is_debug)
    elif index == 3:
        debug('Already login, can execute CLI now', is_debug)
        return ssh_login_result
    else:
        print '''Unknown error'''
        print 'before is %s' % ssh_login_result.before
        print 'after is %s' % ssh_login_result.after
        ssh_login_result.close(force=True)
        return None 
    ssh_login_result.sendline(passwd)
    index = ssh_login_result.expect([pexpect.TIMEOUT, '[Pp]assword', '(root|logger)@.*', 'Aerohive Networks .*#', prompt], timeout=login_timeout)
    if index == 0:
        print '''TimeOut when send password to login Host'''
        print 'before is %s' % ssh_login_result.before
        print 'after is %s' % ssh_login_result.after
        ssh_login_result.close(force=True)
        return None
    elif index == 1:
        print '''Incorrect username or password, please confirm'''
        print 'before is %s' % ssh_login_result.before
        print 'after is %s' % ssh_login_result.after
        ssh_login_result.close(force=True)
        return None
    elif index == 2:
        debug('Login windows/linux clients successfully, can execute cli now')
    elif index == 3:
        debug('Login Aerohive products successfully, can execute cli now')
    elif index == 4:
        debug('Login general products successfully, can execute cli now')
    return ssh_login_result

def execute_cli_via_list(cli_expect_timeout_list, spawn_child, is_debug=True, wait_time=0, ctrl_index_list=[]):
    wait_time=int(wait_time)
    ssh_execute=spawn_child
    cli_index=1
    for cli, cli_expect, timeout in cli_expect_timeout_list:
        ssh_execute.sendline(cli)
        index = ssh_execute.expect([pexpect.TIMEOUT, cli_expect, '--More--', 'More:'], timeout=timeout)
        if index == 0:
            print '''TimeOut when execute CLI, fail in Execute CLI parter'''
            print 'before is %s' % ssh_execute.before
            print 'after is %s' % ssh_execute.after
            ssh_execute.close(force=True)
            return None
        elif index == 1:
            debug('No.%s %s send successfully' % (cli_index,cli), is_debug)
        elif index == 2:
            debug('Aerohive product, cannot show all in a page, send blank to continue', is_debug)
            while index:
                ssh_execute.send(' ')
                index = ssh_execute.expect([cli_expect, '--More--'], timeout=timeout)
        elif index == 3:
            debug('Dell product, cannot show all in a page, send blank to continue', is_debug)
            while index:
                ssh_execute.send(' ')
                index = ssh_execute.expect([cli_expect, 'More:'], timeout=timeout)
        debug('Sleep wait time %s to execute next cli' % wait_time, is_debug)
        sleep(wait_time)
        cli_index+=1
    return ssh_execute

def ssh_logout(spawn_child, logout_timeout=5, is_debug=True):
    ssh_logout_result=spawn_child
    ssh_logout_result.sendcontrol('d')
    index = ssh_logout_result.expect([pexpect.TIMEOUT, 'Connection to .* closed'], timeout=logout_timeout)
    if index == 0:
        logout_retry_index = 0
        logout_retry_times = 2
        logout_retry_num = 0
        while logout_retry_index == 0:
            logout_retry_num += 1
            debug('%s time retry begin' % logout_retry_num, is_debug)
            ssh_logout_result.sendcontrol('d')
            logout_retry_index = ssh_logout_result.expect([pexpect.TIMEOUT, 'Connection to .* closed'], timeout=logout_timeout)
            debug('%s time retry over' % logout_retry_num, is_debug)
            if logout_retry_num == logout_retry_times:
                print 'Retry %s times and logout still failed, return none' % logout_retry_times
                print 'before is %s' % ssh_logout_result.before
                print 'after is %s' % ssh_logout_result.after
                ssh_logout_result.close(force=True)
                return None
    elif index == 1:
        pass
    debug('Free successfully', is_debug)
    return ssh_logout_result
    
class ssh_host:
    def __init__(self, ip, user, passwd, port=22, is_debug=False, absolute_logfile='', prompt='[$#>]', wait_time=0):
        self.ip = ip
        self.user = user
        self.passwd = passwd
        self.port = port
        self.is_debug = is_debug
        self.absolute_logfile = absolute_logfile
        self.prompt = prompt
        self.wait_time = wait_time
        if absolute_logfile == './stdout':
            pass
        else:
            self.absolute_logfile_open = open(absolute_logfile, mode='w')
        print 'SSH %s process start, init parameters............' % ip
    
    def __del__(self):
        if self.absolute_logfile == './stdout':
            pass
        else:
            self.absolute_logfile_open.close()
            absolute_logfile = self.absolute_logfile
            with open(absolute_logfile, mode='r') as absolute_logfile_open:
                originate_logfile = absolute_logfile_open.read()
            correct_logfile = re.sub(' {28}|\r', '', originate_logfile)
            with open(absolute_logfile, mode='w') as absolute_logfile_open:
                absolute_logfile_open.write(correct_logfile)            
        print 'SSH %s process over.' % self.ip
        
    def login(self, login_timeout=10):
        ip = self.ip
        user = self.user
        passwd = self.passwd
        port = self.port
        prompt = self.prompt
        is_debug = self.is_debug
        log_file_path = self.absolute_logfile
        if log_file_path == './stdout':
            log_file_open = []
        else:
            log_file_open = self.absolute_logfile_open
        ssh_login_result=ssh_login(ip,user,passwd,port,prompt,log_file_path,log_file_open,login_timeout,is_debug)
        return ssh_login_result
    
    def execute_command_via_tuple_list(self, cli_expect_timeout_list, spawn_child, ctrl_index_list=[]):
        is_debug = self.is_debug
        wait_time = self.wait_time
        execute_result=execute_cli_via_list(cli_expect_timeout_list, spawn_child, is_debug, wait_time, ctrl_index_list)
        return execute_result
        
        
    def logout(self, spawn_child, logout_timeout=5):
        is_debug = self.is_debug
        debug('....................Quit login status....................', self.is_debug)
        ssh_logout_result=ssh_logout(spawn_child, logout_timeout, is_debug)
        return ssh_logout_result
    
def ssh_execute_cli(ip, user, passwd, cli_list, port, timeout, prompt, logdir, logfile, is_debug, wait_time):
    timeout = int(timeout)
    wait_time = float(wait_time)
    absolute_logfile = logdir + '/' + logfile
    debug('logfile path is %s' % absolute_logfile, is_debug)
    ssh = ssh_host(ip, user, passwd, port, is_debug, absolute_logfile, prompt, wait_time)
    ssh_host_login = ssh.login()
    if ssh_host_login:
        cli_info_list=generate_cli_list(cli_list, prompt, timeout)
        cli_expect_timeout_list = cli_info_list[0]
        ctrl_index_list = cli_info_list[0]                    
        ssh_host_execute = ssh.execute_command_via_tuple_list(cli_expect_timeout_list, ssh_host_login, ctrl_index_list)
    else:
        print 'SSH login failed'
        return None
    ssh_host_logout = ssh.logout(ssh_host_execute)
    return ssh_host_logout

parse = argparse.ArgumentParser(description='SSH host to execute CLI')
parse.add_argument('-d', '--destination', required=True, default=None, dest='desip',
                    help='Destination Host Blade Server IP')

parse.add_argument('-u', '--user', required=False, default='admin', dest='user',
                    help='Login Name')

parse.add_argument('-p', '--password', required=False, default='aerohive', dest='passwd',
                    help='Login Password')

parse.add_argument('-m', '--prompt', required=False, default='AH.*#', dest='prompt',
                    help='The login prompt you want to meet')

parse.add_argument('-o', '--timeout', required=False, default=10, type=int, dest='timeout',
                    help='Time out value for every execute cli step')

parse.add_argument('-l', '--logdir', required=False, default='.', dest='logdir',
                    help='The log file dir')

parse.add_argument('-z', '--logfile', required=False, default='stdout', dest='logfile',
                    help='The log file name')

parse.add_argument('-v', '--command', required=False, action='append', default=[], dest='cli_list',
                    help='The command you want to execute')

parse.add_argument('-debug', '--debug', required=False, default=False, action='store_true', dest='is_debug',
                    help='enable debug mode')

parse.add_argument('-i', '--interface', required=False, default=22, type=int, dest='port',
                    help='ssh port')

parse.add_argument('-f', '--file', required=False, default=False, dest='configfilepath',
                    help='The path of configurefile')

parse.add_argument('-w', '--wait', required=False, default=0, type=float , dest='wait_time',
                    help='wait time between the current cli and next cli')

parse.add_argument('-cli', '--cli', required=False, default='',  dest='cli_example',
                    help='''The cli example you want to loop, such as 'vlan (l1)' ''')

parse.add_argument('-list', '--list', required=False, default='',  dest='loop_list',
                    help='The parameters you want to instead of the cli example')

def main():
    args = parse.parse_args() 
    ip = args.desip
    user = args.user
    passwd = args.passwd
    prompt = args.prompt
    prompt = re.sub('\$', '\\$', prompt)
    timeout = args.timeout
    logdir = args.logdir
    logfile = args.logfile
    cli_list = args.cli_list
    is_debug = args.is_debug
    port = args.port
    wait_time = args.wait_time
    cli_example=args.cli_example
    loop_list=args.loop_list
    loop_list=str_to_list(loop_list, is_debug)
    debug('loop list is as below', is_debug)
    debug(loop_list, is_debug)
    execute_cli_list=[]
    if cli_example and loop_list:
        for i in loop_list:
            execute_cli=re.sub('\(l1\)',str(i),cli_example)
            execute_cli_list.append(execute_cli)
    else:
        execute_cli_list=cli_list
    try:
        ssh_result = ssh_execute_cli(ip, user, passwd, execute_cli_list, port, timeout, prompt, logdir, logfile, is_debug, wait_time)
    except Exception, e:
        print str(e)
    else:
        return ssh_result
            
if __name__ == '__main__':
    ssh_result = main()
    if ssh_result:
        ssh_result.close()
        print 'SSH successfully, exit 0'
        sys.exit(0)
    else:
        print 'SSH failed, exit 1'
        sys.exit(1)
