#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'hshao'

from webui import safe_call, WebUI
from webui.cloud import CLOUD
import time

@safe_call
def go_to_configuration_page():
    wui = WebUI()
    cloud = CLOUD(wui.d("visit.url"), wui.d("visit.title"))
    if wui.session_id is None:
        cloud.to_url_before_login()
        cloud.login(wui.d("menu.name"))
        cloud.wait_until_login_success(popup=wui.d("login.popup_timer"), success_page=wui.d("login.success_page"))
        if wui.d("login.success_page") == 'false':
            return
        else:
            cloud.to_url_after_login(redirect=wui.d("visit.auto_redirect"))
    elif wui.session_id:
        cloud.to_url_before_menu()
        cloud.to_menu(wui.d("menu.name"))
        # cloud.wait_until_login_success(popup=wui.d("login.popup_timer"), success_page=wui.d("login.success_page"))
        # if wui.d("login.success_page") == 'false':
        #     return
        # else:
        #     cloud.to_url_after_login(redirect=wui.d("visit.auto_redirect"))
    else:
        cloud.login_mode()
        cloud.logout()


if __name__ == '__main__':
    go_to_configuration_page()