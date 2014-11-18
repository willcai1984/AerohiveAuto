# -*- coding: UTF-8 -*-
#upload_config.py -r http://10.155.40.228:4444/wd/hub -t ie -f LogFile --parameters upload.type=compare_running_ap_config ap.mgt0_ip=${}

from webui import safe_call, WebUI
from webui.hm import HM

@safe_call
def upload():
    wui = WebUI()
    hm = HM()
    if wui.session_id is None:
        hm.login(wui.d("login.server"),
                 wui.d("login.username"),
                 wui.d("login.password"))
    hm.to_hiveaps_table()
    hm.upload_and_activate_configuration(wui.d("ap.mgt0_ip"), type=wui.d("upload.type"))
    hm.check_update_result(wui.d("ap.mgt0_ip"), time_out=1000)

if __name__ == '__main__':
    upload()