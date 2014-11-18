#!/usr/bin/python

# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class HiveConfig(WebElement):
    hive_tab = (By.XPATH, '//li[@data-dojo-attach-point="nav-hiveProfile"]')
    hive_profile_title = (By.XPATH, '//div[starts-with(@id, "ah/comp/configuration/HiveProfile_")]/div[span="Hive Profile"]')
    new_hive_name = (By.XPATH, '//input[@data-dojo-attach-point="hiveName"]')
    hive_security = (By.XPATH, '//div[starts-with(@id, "ah/comp/configuration/HiveProfile_")]/div[5]/h3')
    encryption_switch_div = (By.XPATH, '//input[@data-dojo-attach-point="encrptionSwitch"]/parent::div')
    encryption_switch_input = (By.XPATH, '//input[@data-dojo-attach-point="encrptionSwitch"]')
    manual_pwd_btn_div = (By.XPATH, '//input[@data-dojo-attach-point="pwdType-manual"]/parent::label')
    manual_pwd_btn_input = (By.XPATH, '//input[@data-dojo-attach-point="pwdType-manual"]')
    manual_share_pwd = (By.XPATH, '//input[@data-dojo-attach-point="norEl"][@data-validid="passwordObs.norEl"]')
    manual_cfm_pwd = (By.XPATH, '//input[@data-dojo-attach-point="cfmEl"][@data-validid="passwordObs.cfmEl"]')
    hive_profile_save_btn = (By.XPATH, '//div[@data-dojo-attach-point="additionalSettingsContentArea"]/descendant::button[@data-dojo-attach-point="saveButton"]')
    hive_profile_success = (By.XPATH, '//div[@data-dojo-attach-point="wrapEl"]/div/h3')
    hive_profile_next_btn = (By.XPATH, '//div[@data-dojo-attach-point="wizardBar"]/div/button[@data-dojo-attach-point="nextBtn"]')
    deploy_page_title =(By.XPATH, '//div[starts-with(@id, "ah/comp/configuration/SelectDevices_")]/div/span')