# -*- coding: UTF-8 -*-
from webui import safe_call, WebUI
from webui.cloud.page import *
from webui.cloud.Login import Login
from webui.cloud.Configuration import Configuration
import random
from selenium import selenium
@safe_call
def hshao_login():
    wui = WebUI()
    login = Login(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    config = Configuration(wui.d("visit.url"), wui.d("visit.title"))
    if wui.session_id is None:
        login.to_url_before_login()
        login.login(wui.d("login.username"),
                  wui.d("login.password"))
        login.wait_until_login_success(wui.d("login.username"))

        config.to_url_home()
        config.to_menu(wui.d("policy.menu_name"))
        config.wait_until_to_menu_success(wui.d("policy.menu_name"))
        config.to_page_before_policy()
        config.create_network_policy(wui.d("policy.name"), wui.d("policy.Description"))
        config.wait_until_create_policy_result(wui.d("policy.success_msg"), check_success=wui.d("policy.check_success"))

    if wui.session_id:
        config.user_profile_srcurce_ip('google', '8.8.8.8')
        config.user_profile_destination_ip('google', '8.8.8.8')
        # config.user_profile_select_net_service()

if __name__ == '__main__':
    hshao_login()
