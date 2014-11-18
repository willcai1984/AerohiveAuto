# -*- coding: UTF-8 -*-

#python cloud_login_positive.py -r http://${sta.ip}:4444/wd/hub -t ie -f logFile --parameters

from webui import safe_call, WebUI
from webui.cloud.Login import Login

@safe_call
def cloud_login_positive():
    wui = WebUI()
    login = Login(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    if wui.session_id is None:
        login.to_url_before_login()
        login.login(wui.d("login.username"),
                  wui.d("login.password"))
        login.wait_until_login_success(wui.d("login.username"))

    else:
        login.login_mode()
        login.logout()

if __name__ == '__main__':
    cloud_login_positive()
