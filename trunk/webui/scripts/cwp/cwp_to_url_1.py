# -*- coding: UTF-8 -*-

from webui import safe_call, WebUI
from webui.cwp import CWP

@safe_call
def cwp_to_url():
    wui = WebUI()
    cwp = CWP(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    cwp.to_url_before_login(location='test_page')
    cwp.to_url_test()
        
if __name__ == '__main__':
    cwp_to_url()
