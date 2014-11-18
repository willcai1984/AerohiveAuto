# -*- coding: UTF-8 -*-
#update_bootstrap.py -r http://10.155.40.228:4444/wd/hub -t ie -f LogFile ap.mgt0_ip=${}

from webui import safe_call, WebUI
from webui.hm import HM

@safe_call
def update():
    wui = WebUI()
    hm = HM()
    if wui.session_id is None:
        hm.login(wui.d("login.server"),
                 wui.d("login.username"),
                 wui.d("login.password"))
    hm.to_hiveaps_table()
    hm.update_bootstrap(wui.d("ap.mgt0_ip"))
    hm.check_update_result(wui.d("ap.mgt0_ip"))
    
if __name__ == '__main__':
    update()