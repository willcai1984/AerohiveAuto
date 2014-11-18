#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'hshao'

from webui import safe_call, WebUI
from webui.cloud.Configuration import Configuration

@safe_call
def deploy_policy():
    wui = WebUI()
    config = Configuration(wui.d("visit.url"), wui.d("visit.title"))

    if wui.session_id:
        config.to_page_deploy_policy()
        config.deploy_policy(wui.d("deploy_policy.check_mac"))
        config.wait_until_to_deploy_policy_success(wui.d("deploy_policy.success_msg"))

    else:
        config.deployedSSID_mode()
        config.logout()


if __name__ == '__main__':
    deploy_policy()