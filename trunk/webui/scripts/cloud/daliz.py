# -*- coding: UTF-8 -*-
from webui import safe_call, WebUI
from webui.cloud.Configuration import Configuration
from webui.cloud.page import *
from selenium.webdriver.common.by import By
import time

@safe_call
def sw_policy_config_stp():
    wui = WebUI()
    config = Configuration(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    if wui.session_id:
        config.to_url_home()
        config.to_menu(wui.d("policy.menu_name"))
        config.wait_until_to_menu_success(wui.d("policy.menu_name"))
        wui.info('go to configuration tab...', True)
        wui.wait_until_element_displayed(daliz_class.configuration_btn)
        wui.click(daliz_class.configuration_btn)
        wui.info('go to create policy and click new policy....', True)
        wui.wait_until_element_displayed(daliz_class.cr_policy)
        wui.click(daliz_class.cr_policy)
        wui.info('create policy for GUI automation test and input policy nane', True)
        policy_name=wui.d("sw_policy_name")
        wui.input(daliz_class.get('policy_name_loc'),policy_name)
        
        wui.info('try to go to device template page...',True)
        wui.click(daliz_class.device_template_page)
        wui.info('get into device template page', True)
        wui.wait_until_element_displayed(daliz_class.add_template)
        wui.click(daliz_class.add_template)
        wui.info('add', True)
        wui.click(daliz_class.add_template_switch)
        wui.info('switch', True)
        wui.click(daliz_class.add_template_switch_2124p)
        wui.info('get into switch template page', True)
        wui.wait_until_element_displayed(daliz_class.input_template_switch_name)
        
        template_name=wui.d("sw_template_name")
        wui.input(daliz_class.get('input_template_switch_name'),template_name)
        wui.info('input switch template name', True)
        wui.click(daliz_class.template_save_btn)
        wui.wait_until_element_displayed(daliz_class.template_save_msg)
        wui.info('save switch template successfully', True)
        wui.click(daliz_class.add_setting_page)
        time.sleep(5)
        wui.wait_until_element_displayed(daliz_class.storm_setting)
        wui.info('go to additional settings', True)
        wui.click(daliz_class.storm_setting)
        time.sleep(2)
        wui.click(daliz_class.storm_access_bc)
        wui.info('enable storm control on access ports, control type is broadcast', True)
        wui.info('try to save the configuration...', True)
        wui.click(daliz_class.storm_control_save)
        time.sleep(1)
        wui.wait_until_element_displayed(daliz_class.storm_control_msg)
        wui.info('save the storm control setting successfully')

if __name__ == '__main__':
    sw_policy_config_stp()
