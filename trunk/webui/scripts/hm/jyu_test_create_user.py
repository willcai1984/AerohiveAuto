# -*- coding: UTF-8 -*-
#upload_config.py -r http://10.155.40.228:4444/wd/hub -t ie -f LogFile --parameters upload.type=compare_running_ap_config ap.mgt0_ip=${}

from webui import safe_call, WebUI
from webui.hm import HM

@safe_call
def create_user():
    wui = WebUI()
    hm = HM()
    if wui.session_id is None:
        hm.login(wui.d("login.server"),
                 wui.d("login.username"),
                 wui.d("login.password"))
    hm.to_hiveaps_table()

if __name__ == '__main__':
    create_user()