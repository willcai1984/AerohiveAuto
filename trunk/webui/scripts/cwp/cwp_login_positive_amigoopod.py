# -*- coding: UTF-8 -*-

#python cwp_login_positive_amigoopod.py -r http://${sta.ip}:4444/wd/hub -t ie -f logFile --parameters

from webui import safe_call, WebUI
from webui.cwp import CWP

@safe_call
def cwp_login_positive_amigoopod():
    wui = WebUI()
    cwp = CWP(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    if wui.session_id is None:
        cwp.to_url_before_login(location='CWP_custom_loginpage_amigopod')
        cwp.login_amigopod(wui.d("login.username"),
                           wui.d("login.password"))
        cwp.wait_until_login_success(popup=wui.d("login.popup_timer"))
        cwp.to_url_after_login()
    elif wui.session_id and wui.d("visit.login_page_exist") == "true":
        cwp.login_amigopod(wui.d("login.username"),
                           wui.d("login.password"))
        cwp.wait_until_login_success(popup=wui.d("login.popup_timer"))
        cwp.to_url_after_login()   
    else:
        cwp.login_mode()
        cwp.logout()
        
if __name__ == '__main__':
    cwp_login_positive_amigoopod()

