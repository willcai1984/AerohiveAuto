# -*- coding: UTF-8 -*-

# cd /opt/auto_case/webui; svn up; python scripts/cwp/cwp_register_positive.py -r http://10.155.40.102:4444/wd/hub -t ie -f test

from webui import safe_call, WebUI
from webui.cwp import CWP

@safe_call
def cwp_register_positive():
    wui = WebUI()
    cwp = CWP(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    if wui.session_id is None:
        cwp.to_url_before_login()
        cwp.register(wui.d("register.first_name"),
                     wui.d("register.last_name"),
                     wui.d("register.email"),
                     wui.d("register.phone"),
                     wui.d("register.visiting"),
                     wui.d("register.reason"))
        cwp.wait_until_login_success()
        cwp.to_url_after_login()
    else:
        cwp.register_mode()
        cwp.logout()

if __name__ == '__main__':
    cwp_register_positive()
