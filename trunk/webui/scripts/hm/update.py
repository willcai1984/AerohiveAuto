# -*- coding: UTF-8 -*-

from webui import safe_call, WebUI
from webui.hm import HM

@safe_call
def update():
    wui = WebUI()
    hm = HM()
    hm.login(wui.d("login.server"),
             wui.d("login.username"),
             wui.d("login.password"))
    if wui.d("update.function") == "upload_config":
        hm.to_hiveaps_table()
        hm.set_image_to_boot(wui.d("ap.mgt0_ip"))
        hm.upload_and_activate_configuration(wui.d("ap.mgt0_ip"), type='compare_running_ap_config')
        hm.upload_and_activate_configuration(wui.d("ap.mgt0_ip"), type='complete')
        hm.get_tech_data(wui.d("ap.mgt0_ip"))

if __name__ == '__main__':
    update()
