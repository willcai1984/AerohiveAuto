#!/usr/bin/python

# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class MacFilter(WebElement):
    ssid_tab_section = (By.XPATH, '//div[@data-dojo-attach-point="ssidTab"]')
    
    optional_setting_element = (By.XPATH, '//div[starts-with(@id, "ah/comp/configuration/SSIDDetailsForm_")]/div[4]/div[1]/h3')
    optional_setting_xpath = (By.XPATH, '''//div[@data-dojo-attach-point="contentArea"]/div/div[4]/div[4]/div[@class="grid_4 first column"]''')
    optional_setting_desc_xpath = (By.XPATH, '''//div[@data-dojo-attach-point="contentArea"]/div/div[4]/div[4]/div[@class="grid_4 column"]''')
    opt_customize_btn = (By.XPATH, '//div[@data-dojo-attach-point="contentArea"]/div/div[4]/div[4]/div[@class="grid_4 last column"]/button')
    
    opt_setting_title = (By.XPATH, '//div[@class="ui-nobd-tle"]/span')
    
    mac_filter_section = (By.XPATH, '//*[@data-dojo-attach-point="newMacFilter"]/ancestor::div[@class="line clearfix"]/parent::div/div[starts-with(@id,"ah/util/AHGrid_")]')
    mac_filter_checkbox = (By.XPATH, '//input[@data-dojo-attach-point="enableFilter"]/parent::label')
    mac_filter_defaction_box = (By.XPATH, '//div[@id="ah/comp/configuration/OptionSettings_0"]/div[7]/div/div')
    mac_filter_defaction_dropdown = (By.XPATH, '//div[@id="ah/comp/configuration/OptionSettings_0"]/div[7]/div[2]/div/a/div/b')
    mac_filter_default_action = (By.XPATH, '//div[@id="ah/comp/configuration/OptionSettings_0"]/div[7]/div[2]/div/a/span')
    mac_filter_defaction_permit = (By.XPATH, '//div[@id="ah/comp/configuration/OptionSettings_0"]/div[7]/div[2]/div/div/ul/li[1]')
    mac_filter_defaction_deny = (By.XPATH, '//div[@id="ah/comp/configuration/OptionSettings_0"]/div[7]/div[2]/div/div/ul/li[2]')
    
    mac_filter_list = (By.XPATH, '//div[@dojoattachevent="onmouseout:_mouseOut"][@aria-activedescendant="ah/util/AHGrid_11Hdr0"]')
    mac_filter_entry_new_btn = (By.XPATH, '//li[@data-dojo-attach-point="newMacFilter"]/span')
    mac_filter_newentry_input_mac = (By.XPATH, '//div[@data-dojo-attach-point="addNewFilter"]/div[1]/div[2]/div/div[1]/input')
    mac_filter_newentry_select_mac_btn = (By.XPATH, '//div[@data-dojo-attach-point="addNewFilter"]/div[1]/div[2]/div/div[1]/span[2]')
    
    mac_entry_oui_apple = (By.XPATH, '//li[@data-id="450971566277"]')
    
    mac_entry_default_action = (By.XPATH, '//div[@id="ah_util_Chosen_10_chzn"]/a/span')
    mac_entry_action_btn = (By.XPATH, '//div[@id="ah_util_Chosen_10_chzn"]/a/div/b')
    mac_entry_action_permit = (By.XPATH, '//div[@id="ah_util_Chosen_10_chzn"]/div/ul/li[1]')
    mac_entry_action_deny = (By.XPATH, '//div[@id="ah_util_Chosen_10_chzn"]/div/ul/li[2]')
    mac_entry_add_btn = (By.XPATH, '//button[@data-dojo-attach-point="addBtn"]')
    
    added_mac_entry_checkbox = (By.XPATH, '//div[starts-with(@id, "ah/comp/configuration/OptionSettings_")]/div[8]/div[3]/div[2]/div/div/div/div/div/table/tbody/tr/td[1]')
    added_mac_entry_oui_name = (By.XPATH, '//div[starts-with(@id, "ah/comp/configuration/OptionSettings_")]/div[8]/div[3]/div[2]/div/div/div/div/div/table/tbody/tr/td[2]')
    added_mac_entry_action = (By.XPATH, '//div[starts-with(@id, "ah/comp/configuration/OptionSettings_")]/div[8]/div[3]/div[2]/div/div/div/div/div/table/tbody/tr/td[3]')
    
    optional_setting_save_btn = (By.XPATH, '//div[starts-with(@id, "ah/comp/configuration/OptionSettings_")]/descendant::div/button[@data-dojo-attach-point="saveButton"]')
    
    ssid_saved_btn = (By.XPATH, '//div[@data-dojo-attach-point="contentArea"]/descendant::button[@data-dojo-attach-point="saveButton"]')
    ssid_saved_success = (By.XPATH, '//div[@class="ui-tipbox-con"]/h3')
    
    
    
    
    
    
    
    
    
    