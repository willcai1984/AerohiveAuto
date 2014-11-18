# -*- coding: UTF-8 -*-

from webui import safe_call, WebUI
from webui.cwp import CWP

@safe_call
def amigopod_login_positive():
    wui = WebUI()
    cwp = CWP(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    if wui.session_id is None:
        cwp.to_url_before_login(location='amigopod_management_login')
        cwp.login_to_amigopod_management(wui.d("login.username"),
                                         wui.d("login.password"))
    else:
        cwp.logout_amigopod_management()
        
if __name__ == '__main__':
    amigopod_login_positive()
