# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class MainPage(WebElement):
    main_page_title = 'Guided Configuration'
    
    home_lnk = (By.LINK_TEXT, 'Home')
    monitor_lnk = (By.LINK_TEXT, 'Monitor')

    login_name = (By.ID, 'login_name')
    logout_menu = (By.XPATH, '//a[contains(text(), "Log") and contains(text(), "Out") and contains(text(), "...")]')
    logout_btn = (By.LINK_TEXT, 'Log Out')
    switch_vhm_btn = (By.LINK_TEXT, 'Switch Virtual HM')
    next_link = (By.ID, 'ssnext')
    
    logout_vhm_btn = (By.XPATH, '//a[contains(text(), "Log") and contains(text(), "Out")]')

    confirm_dlg = (By.XPATH, '//div[@id="confirmDialog"]')
    confirm_dlg_yes_btn = (By.XPATH, '//div[@id="confirmDialog"]//button[text()="Yes"]')
    confirm_dlg_no_btn = (By.XPATH, '//div[@id="confirmDialog"]//button[contains(text(), "No")]')

    @classmethod
    def locate_vhm_link(cls, text):
        return (By.LINK_TEXT, '%s' % text)
        #return (By.XPATH, '//div[@id="switch"]/div[@class="bd"]/ul[@class="first-of-type"]/li/a[contains(text(), "%s")]' % text)