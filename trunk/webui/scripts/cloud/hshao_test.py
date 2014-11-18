#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'hshao'

from webui import safe_call, WebUI
from webui.cloud import CLOUD
import time


@safe_call
def create_network_policy():
    wui = WebUI()
    cloud = CLOUD(wui.d("visit.url"), wui.d("visit.title"))

    if wui.session_id:
        cloud.to_url_home()
        cloud.to_menu(wui.d("policy.menu_name"))
        cloud.wait_until_to_menu_success(wui.d("policy.menu_name"))
        cloud.to_page_before_policy()
        cloud.create_network_policy(wui.d("policy.name"), wui.d("policy.Description"))
        cloud.wait_until_create_policy_result(wui.d("policy.success_msg"), check_success=wui.d("policy.check_success"))

        # cloud.to_page_before_deployed_ssid()
        # cloud.create_SSID(wui.d("ssid.name"), wui.d("ssid.name"))
        # cloud.wait_until_create_ssid_result(wui.d("ssid.success_msg"), check_success=wui.d("ssid.check_success"))
        #
        # cloud.to_page_device_templates()
        # cloud.to_page_additional_settings()
        #
        # cloud.to_page_deploy_policy()
        # cloud.wait_until_to_deploy_policy_page(wui.d("deploy_policy.menu_title"))
        # cloud.select_checkbox_deploy_policy(wui.d("deploy_policy.check_mac"), wui.d("deploy_policy.dut_number"))
        # cloud.wait_until_to_deploy_policy_success(wui.d("deploy_policy.success_msg"), check_success=wui.d("deploy_policy.check_success"))


        # cloud.wait_until_login_success(popup=wui.d("login.popup_timer"), success_page=wui.d("login.success_page"))
        # if wui.d("login.success_page") == 'false':
        #     return
        # else:
        #     cloud.to_url_after_login(redirect=wui.d("visit.auto_redirect"))
    else:
        cloud.policy_mode()
        cloud.logout()


if __name__ == '__main__':
    create_network_policy()