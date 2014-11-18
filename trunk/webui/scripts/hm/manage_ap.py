# -*- coding: UTF-8 -*-

from webui import safe_call, WebUI
from webui.hm import HM

@safe_call
def upload_and_activate_configuration():
    wui = WebUI()
    hm = HM()
    hm.login(wui.d("login.server"),
    		 wui.d("login.username"),
             wui.d("login.password"))
    hm.to_hiveaps_table()
    hm.upload_and_activate_configuration(wui.d("ap.mgt0_ip"))

if __name__ == '__main__':
    upload_and_activate_configuration()