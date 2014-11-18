# -*- coding: UTF-8 -*-

# java -Xms128m -Xmx512m -jar selenium-server-standalone-2.20.0.jar -log selenium.log
# 
# set PYTHONPATH=D:\tommy\prj_code\Aerohive\auto_case
# 
# python test.py -r http://127.0.0.1:4444/wd/hub -f test
# python test.py -r http://127.0.0.1:4444/wd/hub -f test -t ie
# 
# java -Xms128m -Xmx512m -jar selenium-server-standalone-2.20.0.jar -timeout 600 -log selenium.log
# 
# python test.py -r http://127.0.0.1:4444/wd/hub -f test --preserve-session
# python test.py -r http://127.0.0.1:4444/wd/hub -f test --session-id 1330578767969
# 
# 
# staf local fs copy file /opt/auto_case/webui/profile/IE_Options_Setting_Win7.vbs tofile "d:\\webui\IE_Options_Setting_Win7.vbs" tomachine 192.168.101.91
# staf local fs copy file /opt/auto_case/webui/3rd/selenium-server-standalone-2.20.0.jar tofile "d:\\webui\selenium-server-standalone-2.20.0.jar" tomachine 192.168.101.91
# 
# staf 192.168.101.91 process start shell command "java -Xms512m -Xmx1024m -jar selenium-server-standalone-2.20.0.jar -log .\\logs\\selenium.log" workdir "d:\\webui" workload webui
# staf 192.168.101.91 process list webui
# staf 192.168.101.91 process stop workload webui using sigkillall
# 
# export PYTHONPATH=/opt/auto_case
# cd /opt/auto_case/webui; svn up; python test/test.py -r http://192.168.101.91:4444/wd/hub -t ie -f test
#
# tar cfz xxx.tgz test.html test_pic/
# scp root@10.155.40.100:/opt/auto_case/webui/xxx.tgz .
# 
# staf 192.168.101.91 process start shell command "java -Xms128m -Xmx512m -jar selenium-server-standalone-2.20.0.jar -timeout 600 -log selenium.log" workdir "d:\\webui" workload webui
# cd /opt/auto_case/webui; svn up; python test/test.py -r http://192.168.101.91:4444/wd/hub -t ie -f test --preserve-session
# cd /opt/auto_case/webui; svn up; python test/test.py -r http://192.168.101.91:4444/wd/hub -t ie -f test --session-id 1330578767969

from webui import safe_call, WebUI
from webui.hm import HM
from webui.hm.vhm_management import VHMManagementForm

def login_hm():
    wui = WebUI()
    
    import platform
    if platform.system() == 'Windows':
        server = 'https://10.155.40.100/'
    else:
        server = wui.d('hm_server')
    admin = wui.d('user_admin.name')
    admin_pwd = wui.d('user_admin.passwd')
    
    hm = HM()
    hm.login(server, admin, admin_pwd)

def logout_hm():
    wui = WebUI()
    hm = HM()
    hm.admin_mode()
    hm.logout()
    
@safe_call
def webop():
    wui = WebUI()
    if wui.session_id is None:
        login_hm()
    else:
        logout_hm()

@safe_call
def test():
    wui = WebUI()
    print wui.d('user_admin.name')
    print wui.d('test.test_property')

if __name__ == '__main__':
    test()
