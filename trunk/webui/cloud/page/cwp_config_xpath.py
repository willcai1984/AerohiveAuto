#!/usr/bin/python

# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class CWPConfig(WebElement):
    cwp_tab = (By.XPATH, '//div[@data-dojo-attach-point="ssidTab"]/div/div[2]/div[2][a="Captive Web Portal"]')
    cwp_enable_switch = (By.XPATH, '//input[@data-dojo-attach-point="cwpSwitch"]/parent::div')
    cwp_to_use_input = (By.XPATH, '//div[starts-with(@id, "ah/util/form/CWPChooser_")]/div/input')
    cwp_to_use_save = (By.XPATH, '//div[starts-with(@id, "ah/util/form/CWPChooser_")]/div/span[@data-dojo-attach-point="ipSta"]')
    new_cwp_title = (By.XPATH, '//div[starts-with(@id, "ah/comp/configuration/CreateCWP_")]/div[span="New Captive Web Portal"]')
    cwp_name = (By.XPATH, '//input[@data-dojo-attach-point="cwpName"]')
    new_cwp_save = (By.XPATH, '//div[starts-with(@id, "ah/comp/configuration/CreateCWP_")]/div[10]/div/button[@data-dojo-attach-point="saveButton"]')
    new_ssid_save = (By.XPATH, '//div[starts-with(@id, "ah/comp/configuration/SSIDDetailsForm_")]/div[5]/div/button[@data-dojo-attach-point="saveButton"]')
    new_ssid_success = (By.XPATH, '//div[@class="ui-tipbox-con"]/h3')
    ssid_tab = (By.XPATH, '//div[@data-dojo-attach-point="ssidTab"]')
    cwp_name_input_element = (By.XPATH, '//div[@data-dojo-attach-point="ipElWrap"]/parent::div')
    