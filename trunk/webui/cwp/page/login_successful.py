# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class LoginSuccessfulPage(WebElement):
    login_successful_page_title = 'Login Successful'

class LoginSuccessfulNPDPage(WebElement):
    login_successful_txt = (By.XPATH, '//p[contains(text(), "Registration Successful!")]') 
