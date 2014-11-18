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
    hm.config_update_device_new(wui.d("upload.policy"), wui.d("ap.mgt0_ip"), type=wui.d("upload.type"))
    hm.check_update_result(wui.d("ap.mgt0_ip"), result_page='config')

if __name__ == '__main__':
    upload()