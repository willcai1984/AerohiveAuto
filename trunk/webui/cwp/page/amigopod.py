# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class AmigopodLoginPage(WebElement):
    login_page_title = 'amigopod :: Login'
    
    username_txt = (By.XPATH, '//input[@name="username"]')
    password_txt = (By.XPATH, '//input[@name="password"]')
    
    login_btn = (By.XPATH, '//input[@value="Log In"]')

class AmigopodAdministratorPage(WebElement):
    page_title = 'amigopod :: Administrator'

    logout_link = (By.XPATH, '//a[text()="Logout"]')