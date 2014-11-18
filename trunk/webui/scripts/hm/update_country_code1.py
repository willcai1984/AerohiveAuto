# -*- coding: UTF-8 -*
#update_country_code.py -r http://$(sta.ip):4444/wd/hub -t ie -f LogFile --parameters ap.mgt0_ip=${} ap.couontry_code=156

from webui import safe_call,WebUI
from webui.hm import HM

@safe_call
def update():
    wui=WebUI()
    hm=HM()
    if wui.session_id is None:
        hm.login(wui.d("login.server"),
                 wui.d("login.username"),
                 wui.d("login.password"))
    hm.to_hiveaps_table()
    hm.update_country_code1(wui.d("ap.mgt0_ip"))
    hm.check_update_result(wui.d("ap.mgt0_ip"))
    
if __name__ == '__main__':
    update()    
    
