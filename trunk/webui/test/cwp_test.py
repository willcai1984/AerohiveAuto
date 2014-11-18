# -*- coding: UTF-8 -*-

# 10.155.40.228 - remote desktop bridge
# 10.155.40.101, 102, 103 - windows station
# https://192.168.10.101/ - hm server
# 
# staf local fs copy file /opt/auto_case/webui/profile/IE_Options_Setting_Win7.vbs tofile "d:\\webui\IE_Options_Setting_Win7.vbs" tomachine 10.155.40.102
# staf local fs copy file /opt/auto_case/webui/3rd/selenium-server-standalone-2.20.0.jar tofile "d:\\webui\selenium-server-standalone-2.20.0.jar" tomachine 10.155.40.102
# 
# staf 10.155.40.102 process start shell command "java -Xms512m -Xmx1024m -jar selenium-server-standalone-2.20.0.jar -log .\\logs\\selenium.log" workdir "d:\\webui" workload webui
# staf 10.155.40.102 process list webui
# staf 10.155.40.102 process stop workload webui using sigkillall
# 
# export PYTHONPATH=/opt/auto_case
# cd /opt/auto_case/webui; svn up; python test/cwp_test.py -r http://10.155.40.102:4444/wd/hub -t ie -f test
# 
# tar cfz xxx.tgz test.html test_pic/
# scp root@10.155.40.100:/opt/auto_case/webui/xxx.tgz .

from webui import safe_call, WebUI
from webui.cwp import CWP

@safe_call
def webop():
    wui = WebUI()
    cwp = CWP(wui.d("visit.url"), wui.d("visit.title"))
    cwp.to_url_before_login()
    cwp.register(wui.d("register.first_name"),
                 wui.d("register.last_name"),
                 wui.d("register.email"),
                 wui.d("register.phone"),
                 wui.d("register.visiting"),
                 wui.d("register.reason"))
    cwp.to_url_after_login()
    cwp.logout()
        
if __name__ == '__main__':
    webop()
