# -*- coding: UTF-8 -*-

from webui import safe_call, WebUI
from webui.cwp import CWP

@safe_call
def cwp_register_negative():
    wui = WebUI()
    cwp = CWP(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    cwp.to_url_before_login()
    cwp.register123(wui.d("register.first_name"),
                    wui.d("register.last_name"),
                    wui.d("register.email"),
                    wui.d("register.visiting"))
    cwp.wait_until_login_fail(redirect_page_name='registration123')

if __name__ == '__main__':
    cwp_register_negative()
