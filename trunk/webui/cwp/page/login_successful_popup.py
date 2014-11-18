# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class LoginSuccessfulPopupPage(WebElement):
    login_successful_popup_page_title = 'Network Access Timer'
    
    left_div = (By.ID, 'left')
    
    logou_btn = (By.XPATH, '//input[@value="Log Out"]')
