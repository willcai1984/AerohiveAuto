# -*- coding: UTF-8 -*-
#!/usr/bin/python

from selenium.webdriver.common.by import By
from webui import WebElement

class daliz_class(WebElement):
    configuration_btn = (By.XPATH, '//li[@data-dojo-attach-point="configurationtab"]/a')
    cr_policy = (By.XPATH, '//li[@data-dojo-attach-point="newNetworkPolicy"]/span')
    policy_name_loc = (By.XPATH, '//input[@placeholder="Network Policy Name"]')
    device_template_page = (By.XPATH, '//li[@data-dojo-attach-point="wiredconnPage"]')
    add_template = (By.XPATH, '//span[@data-dojo-attach-point="newDevice"]')
    add_template_switch = (By.XPATH, '//a[@data-dojo-attach-point="secondTrigger-switch"]')
    add_template_switch_2124p = (By.XPATH, '//a[@data-dojo-attach-point="tmpl-2124"]')
    input_template_switch_name = (By.XPATH, '//input[@data-dojo-attach-point="tplName"]')
    template_save_btn = (By.XPATH, '//div[@data-dojo-attach-point="deviceTmpl"]/div/div[7]/div/button[@data-dojo-attach-point="saveButton"]')
    template_save_msg = (By.XPATH, '//h3[@data-dojo-attach-point="textEl"]')
    add_setting_page = (By.XPATH, '//li[@data-dojo-attach-point="additionalSettingsPage"]')
    stp_setting = (By.XPATH, '//li[@data-dojo-attach-point="nav-stpConfigurations"]')
    stp_setting_trigger = (By.XPATH, '//input[@data-dojo-attach-point="stpSwitch"]')
    storm_setting = (By.XPATH, '//li[@data-dojo-attach-point="nav-stormControl"]')
    storm_access_bc = (By.XPATH, '//div[1]/div/ul/li[1]/label[@class="checkbox"]')
    deploy_page = (By.XPATH, '//li[@data-dojo-attach-point="selectDevicesPage"]')
    upload_btn = (By.XPATH, '//button[@data-dojo-attach-point="upload"]')
    rm_policy = (By.XPATH, '//li[@data-dojo-attach-point="removeNetworkPolicy"]/span')
    rm_policy_yes = (By.XPATH, '//button[@data-dojo-attach-point="yesBtn"]')
    back_policy_list = (By.XPATH, '//li[@data-dojo-attach-point="backPolicyList"]')
    upload_dialog_title = (By.XPATH, '//h5[@data-dojo-attach-point="stepTitle"]')
    upload_dialog_btn = (By.XPATH, '//div[@data-dojo-attach-point="wizardFooter"]/a[@data-dojo-attach-point="uploadBtn"]')
    upload_success_msg = (By.XPATH, '//h3[@data-dojo-attach-point="textEl"]')
    storm_control_save = (By.XPATH, '//div[starts-with(@id, "ah/comp/configuration/StormControl_")]/div[6]/div/button[@data-dojo-attach-point="saveButton"]')
    storm_control_msg = (By.XPATH, '//h3[@data-dojo-attach-point="textEl"]')
    
    
    
    