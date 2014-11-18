# -*- coding: UTF-8 -*
#modify.py -r http://{sta.ip}:4444/wd/hub -t ie -f LogFile --parameters modify.mgt0_ip= modify.name=disable_DHCP disable_DHCP.mgt0_ip= disable_DHCP.subnet_mask= 

from webui import safe_call,WebUI
from webui.hm import HM

@safe_call
def modify():
    wui=WebUI()
    hm=HM()
    if wui.session_id is None:
        hm.login(wui.d("login.server"),
                 wui.d("login.username"),
                 wui.d("login.password"))
    hm.to_hiveaps_table()                 
    hm.modify(wui.d("modify.mgt0_ip"), wui.d("modify.name"))
    
if __name__ == '__main__':
    modify()    
    
