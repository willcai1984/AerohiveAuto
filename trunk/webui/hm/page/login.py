# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class LoginPage(WebElement):
    login_page_title = 'HiveManager Login'
    
    username_txt = (By.ID, 'userName')
    password_txt = (By.ID, 'authenticateFormID_password')
    login_btn = (By.CSS_SELECTOR, 'img.dinl')