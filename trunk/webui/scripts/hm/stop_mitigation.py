# -*- coding: UTF-8 -*-

from webui import safe_call, WebUI
from webui.hm import HM

@safe_call
def main():
    wui = WebUI()
    hm = HM()
    if wui.session_id is None:
        hm.login(wui.d("login.server"),
                 wui.d("login.username"),
                 wui.d("login.password"))
    hm.to_hiveaps_table(type='rogue')
    wui.unregister_cleanup(hm.logout)
    hm.stop_mitigation(wui.d("ap.ssid"), wui.d("ap.mac"), wui.d("ap.reporting_hostname"))             

if __name__ == '__main__':
    main()