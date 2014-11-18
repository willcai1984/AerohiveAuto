#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'hshao'

from webui import safe_call, WebUI
from webui.apollo_gui.operation.OPERATION_WirelessConnectivity import Configuration

@safe_call
def create_network_policy():
    wui = WebUI()
    config = Configuration(wui.d("visit.url"), wui.d("visit.title"))

    if wui.session_id:
        config.to_url_home()
        config.to_menu('Configuration')
 #       config.wait_until_to_menu_success('Configuration')
        config.click_add_network_policy_button()
        config.create_network_policy(wui.d("policy.name"), wui.d("policy.Description"))
        config.wait_until_create_policy_result(wui.d("policy.success_msg"), check_success=wui.d("policy.check_success"))

    else:
        config.policy_mode()
        config.logout()


if __name__ == '__main__':
    print "-----------------------------"
    create_network_policy()