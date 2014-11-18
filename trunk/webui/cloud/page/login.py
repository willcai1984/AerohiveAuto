# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class LoginPage(WebElement):
    login_page_title = 'HiveManager NG'
    username_txt = (By.XPATH, '//input[@data-dojo-attach-point="username"]')
    password_txt = (By.XPATH, '//input[@data-dojo-attach-point="password"]')
    login_btn = (By.XPATH, '//input[@data-dojo-attach-point="loginAction"]')
    invitation_txt = (By.XPATH, '//input[@data-dojo-attach-point="keyInput"]')
    invitation_btn = (By.XPATH, '//input[@data-dojo-attach-point="inviteAction"]')

class LoginSuccessfulPage(WebElement):
    user_name = (By.XPATH, '//span[@data-dojo-attach-point="userNameEl"]')

class LoginSuccessfulPopupPage(WebElement):
    login_successful_popup_page_title = 'HiveManager NG'
    home_top = (By.XPATH, '//*[@id="header"]/div/div/ul/li[1]/a')
    logou_btn = (By.XPATH, '//*[@id="header"]/div/div/div/div[3]/div[2]/ul/li')