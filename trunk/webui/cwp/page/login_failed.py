# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class LoginFailedPage(WebElement):
    login_failed_page_title = 'Login Unsuccessful'
    login_failed_page_title2 = 'Failure'

class LoginFailedNPDPage(WebElement):
    login_failed_txt = (By.ID, 'reason') 
