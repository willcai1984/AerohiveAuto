# -*- coding: UTF-8 -*-
#upload_config.py -r http://10.155.40.228:4444/wd/hub -t ie -f LogFile --parameters upload.type=compare_running_ap_config ap.mgt0_ip=${}

from webui import safe_call, WebUI
from webui.ca import CA

@safe_call
def test1():
    wui = WebUI()
    ca = CA()
    if wui.session_id is None:
        ca.login(wui.d("login.server"),
                 wui.d("login.username"),
                 wui.d("login.password"))
    ca.to_hiveaps_table()
    ca.upload_and_activate_configuration(wui.d("ap.mgt0_ip"), type=wui.d("upload.type"))
    ca.check_update_result(wui.d("ap.mgt0_ip"))

if __name__ == '__main__':
    test1()