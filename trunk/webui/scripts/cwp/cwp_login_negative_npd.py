# -*- coding: UTF-8 -*-

from webui import safe_call, WebUI
from webui.cwp import CWP

@safe_call
def cwp_login_negative_npd():
    wui = WebUI()
    cwp = CWP(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    if wui.session_id is None:    
        cwp.to_url_before_login(location='npd_login')
        cwp.login_npd(wui.d("login.username"),
                      wui.d("login.password"))
        cwp.wait_until_login_fail(failed_page=wui.d("login.failed_page"), redirect_page_name=wui.d("redirect.page_name"))
    elif wui.session_id and wui.d("visit.login_page_exist") == "true":
        cwp.login_npd(wui.d("login.username"),
                      wui.d("login.password"))
        cwp.wait_until_login_fail(failed_page=wui.d("login.failed_page"), redirect_page_name=wui.d("redirect.page_name"))
        
if __name__ == '__main__':
    cwp_login_negative_npd()
