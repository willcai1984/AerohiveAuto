# -*- coding: UTF-8 -*-

from webui import safe_call, WebUI
from webui.hm import HM
from webui.cwp import CWP

@safe_call
def main():
    wui = WebUI()
    hm = HM()
    if wui.session_id is None:
        hm.login(wui.d("login.server"),
                 wui.d("login.username"),
                 wui.d("login.password"))
    hm.test()             
    
@safe_call
def main1():
    wui = WebUI()
    cwp = CWP(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    cwp.test()      

if __name__ == '__main__':
    main()