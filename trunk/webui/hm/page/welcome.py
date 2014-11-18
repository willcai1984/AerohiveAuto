# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class WelcomePage(WebElement):
    welcome_page_title = 'Welcome to Aerohive HiveManager'

    hive_name_txt = (By.ID, 'startHere_networkName')
    hive_mgt_passwd_txt = (By.ID, 'adminPassword')
    hive_mgt_passwd_confirm_txt = (By.ID, 'cfAdminPassword')
    quick_ssid_passwd_txt = (By.ID, 'quickPassword')
    quick_ssid_passwd_confirm_txt = (By.ID, 'cfQuickPassword')
    enterprise_mode_radio = (By.XPATH, '//label[starts-with(text(), "Enterprise")]/../input[@name="hmModeType"]')
    
    continue_btn = (By.XPATH, '//input[@value="Continue"]')
    