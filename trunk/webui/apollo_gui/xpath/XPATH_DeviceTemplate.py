#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'Tiesong'

from selenium.webdriver.common.by import By
from webui import WebElement

class DeviceTemplatePage(WebElement):
    popup_msg = (By.XPATH, '//h3[@data-dojo-attach-point="textEl"]')
    device_template_page_title = (By.XPATH,'''//div[@data-dojo-attach-point="accesspointListArea"]/div[span="Device Templates"]''')
    device_template_page_wzard_menu = (By.XPATH,'''//li[@data-dojo-attach-point="wiredconnPage"]/span[@class="wiz-item-des"]''')
    new_btn = (By.XPATH, '''//span[@data-dojo-attach-point="newDevice"]''')
    next_btn = (By.XPATH, '''//button[@data-dojo-attach-point="nextBtn"]''')
    ap230_tmp = (By.XPATH,'''//div[starts-with(@id,'dojox_grid__View_')]/descendant::td[a="AP230"]/a''')
    ap230_tmp_page_open = (By.XPATH, '''//div[@class="ui-nobd-tle mt20"]''')
    select_wifi0 = (By.XPATH,'''//div[@data-dojo-attach-point="wireless-first"]''')
    select_wifi1 = (By.XPATH,'''//div[@data-dojo-attach-point="wireless-second"]''')
    assign_btn = (By.XPATH,'''//div[@data-dojo-attach-point="assignBtn"]''')
    create_new = (By.XPATH,'''//a[@data-dojo-attach-point="createRP"]''')
    new_rp_page_open = (By.XPATH,'''//div[span="Radio Profile"]/span''')
    radio_profile_name_text = (By.XPATH, '''//input[@data-dojo-attach-point="radioProfileName"]''')
    save_radio_profile_button = (By.XPATH,'''//div[starts-with(@id,"ah/comp/configuration/deviceTemplate/RadioProfile")]/descendant::button[@data-dojo-attach-point="saveButton"]''')
    save_template_button = (By.XPATH,'''//div[starts-with(@id,"ah/comp/configuration/deviceTemplate/APTemplate")]/descendant::button[@data-dojo-attach-point="saveButton"]''')
    



