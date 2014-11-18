# -*- coding: UTF-8 -*-

# ssh -CNfg -L 443:192.168.101.94:443 admin@192.168.101.94
# 
# 10.155.40.228 - remote desktop bridge
# 192.168.101.91, 10.155.40.106 - windows pc
# https://192.168.101.94/ - hm server
# 
# staf local fs copy file /opt/auto_case/webui/profile/IE_Options_Setting_Win7.vbs tofile "d:\\webui\IE_Options_Setting_Win7.vbs" tomachine 192.168.101.91
# staf local fs copy file /opt/auto_case/webui/3rd/selenium-server-standalone-2.20.0.jar tofile "d:\\webui\selenium-server-standalone-2.20.0.jar" tomachine 192.168.101.91
# 
# staf 192.168.101.91 process start shell command "java -Xms512m -Xmx1024m -jar selenium-server-standalone-2.20.0.jar -log .\\logs\\selenium.log" workdir "d:\\webui" workload webui
# staf 192.168.101.91 process list webui
# staf 192.168.101.91 process stop workload webui using sigkillall
# 
# export PYTHONPATH=/opt/auto_case
# cd /opt/auto_case/webui; svn up; python test/hm_test.py -r http://192.168.101.91:4444/wd/hub -t ie -f test
# 
# tar cfz xxx.tgz test.html test_pic/
# scp root@10.155.40.100:/opt/auto_case/webui/xxx.tgz .

from webui import safe_call, WebUI
from webui.hm import HM
from webui.hm.vhm_management import VHMManagementForm

def create_vhm():
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
    hm.to_vhm_management_page()
    vhm_mgt_frm = VHMManagementForm(hm)
    if vhm_mgt_frm.has_vhm(wui.d('vhm_account.vhm_name')):
        vhm_mgt_frm.remove_vhm(wui.d('vhm_account.vhm_name'))
    vhm_mgt_frm.add_vhm(wui.d('vhm_account.vhm_name'), 
                        wui.d('vhm_account.max_ap'), 
                        wui.d('vhm_account.admin_mail_addr'), 
                        wui.d('vhm_account.admin_name'), 
                        wui.d('vhm_account.admin_passwd'))
    
    hm.logout()

def login_vhm():
    wui = WebUI()
    
    import platform
    if platform.system() == 'Windows':
        server = 'https://10.155.40.100/'
    else:
        server = wui.d('hm_server')
    vhm_admin = wui.d('vhm_account.admin_name')
    vhm_admin_pwd = wui.d('vhm_account.admin_passwd')

    hm = HM()
    hm.login_by_vhm(server, vhm_admin, vhm_admin_pwd, 
                    wui.d('vhm_welcome.hive_name'), 
                    wui.d('vhm_welcome.hive_mgt_passwd'), 
                    wui.d('vhm_welcome.quick_ssid_passwd'))
    
    hm.logout()
    
@safe_call
def webop():
    create_vhm()
    login_vhm()
    
if __name__ == '__main__':
    webop()
