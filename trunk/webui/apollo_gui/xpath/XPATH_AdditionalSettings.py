#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'Tiesong'

from selenium.webdriver.common.by import By
from webui import WebElement

    
class Hive(WebElement):
    additionalsettings_page_wzard_menu = (By.XPATH,'''//li[@data-dojo-attach-point="additionalSettingsPage"]/span[@class="wiz-item-des"]''')
    nav_hive = (By.XPATH,'''//li[@data-dojo-attach-point="nav-hiveProfile"]''')
    hive_profile = (By.XPATH, '''//div[starts-with(@id,"ah/comp/configuration/additional/HiveProfile")]/descendant::div[@class="ui-tle"]''')
    hive_name = (By.XPATH,'''//input[@data-dojo-attach-point="hiveName"]''')
    traffic_port = (By.XPATH,'''//input[@data-dojo-attach-point="trafficPort"]''')
    btn_macdos_hive = (By.XPATH,'''//button[@data-dojo-attach-point="macDos-hive"]''')
    security_title = (By.XPATH,'''//*[starts-with(@id,"ah/comp/configuration/additional/HiveProfile_")]/descendant::div[h3="Security"]''')
    macdoc_hive_popup = (By.XPATH,'''//div[@data-dojo-attach-point="PROBE_REQ"]/descendant::label[@class="form-label"]''')
    input_probeREQ_value = (By.XPATH,'''//input[@data-dojo-attach-point="probeRequestAlarmThreshold"]''')
    btn_save_macDOS_dialog = (By.XPATH,'''//button[@data-dojo-attach-point="saveDialog"]''')
    btn_save_hiveprofile = (By.XPATH,'''//*[starts-with(@id,"ah/comp/configuration/additional/HiveProfile_")]/descendant::button[@data-dojo-attach-point="saveButton"]''')
    popup_msg = (By.XPATH, '//*[@class="ui-tipbox-title"]')

