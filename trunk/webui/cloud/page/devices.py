#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'hshao'

from selenium.webdriver.common.by import By
from webui import WebElement

class DevicesElement(WebElement):
    menu_successful_page_menu_title = 'Devices'
    sn_td = (By.XPATH, '//div[starts-with(@id,"ah/comp/common/UserHomePage_")]/descendant::tr[td="%s"]')
    sn_checkbox_td = (By.XPATH, '//div[starts-with(@id,"ah/comp/common/UserHomePage_")]/descendant::tr[td="%s"]/td')
    sn_checkbox_div = (By.XPATH, '//div[starts-with(@id,"ah/comp/common/UserHomePage_")]/descendant::tr[td="%s"]/td/div')
    next_page_btn = (By.XPATH, '//div[starts-with(@id,"dojox_grid_enhanced_plugins__Paginator")]/descendant::div[@title="Next Page"]')
    new_btn = (By.XPATH, '//li[@data-dojo-attach-point="onboardDevices"]/span')

    popup_div_title = (By.XPATH, '//h5[@data-dojo-attach-point="stepTitle"]')

    new_device_title_msg = 'Add Aerohive Devices'
    add_devices_btn = (By.XPATH, '//button[@data-dojo-attach-point="startOwnDevice"]')

    reg_devices_title_msg = 'Register my Aerohive Devices'
    sn_radio = (By.XPATH, '//input[@data-dojo-attach-point="manualEntry"]/parent::label')
    sn_text = (By.XPATH, '//*[@data-dojo-attach-point="serialNumbers"]')

    my_devices_title_msg = 'My Aerohive Devices'

    deploy_policy_title_msg = 'Deploy a Network Policy'
    deploy_policy_toggle = (By.XPATH, '//input[@data-dojo-attach-point="deployPolicyToggle"][%s]/parent::div')
    deploy_policy_toggle_checkbox = (By.XPATH, '//input[@data-dojo-attach-point="deployPolicyToggle"][%s]')

    congratulations_title_msg = 'Congratulations!'



    next_btn = (By.XPATH, '//a[@data-dojo-attach-point="wizardNextStepBtn"]')
    close_btn = (By.XPATH, '//a[@data-dojo-attach-point="closeDialog"]')
    previous_btn = (By.XPATH, '//a[@data-dojo-attach-point="wizardPrevStepBtn"]')
    finish_btn = (By.XPATH, '//div[@data-dojo-attach-point="wizardFooter"]/a[@data-dojo-attach-point="wizardFinishStepBtn"]')

    remove_btn = (By.XPATH, '//li[@data-dojo-attach-point="removeDevice"]/span')
    popup_div_msg = (By.XPATH, '//div[@data-dojo-attach-point="msgEl"]')
    yes_btn = (By.XPATH, '//button[@data-dojo-attach-point="yesBtn"]')
    handle_msg_el = (By.XPATH, '//div[@data-dojo-attach-point="wrapEl"]/div/h3[@data-dojo-attach-point="textEl"]')
    handle_msg = 'Device deleted successfully.'

