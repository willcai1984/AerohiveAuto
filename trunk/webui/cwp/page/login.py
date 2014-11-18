# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class LoginPage(WebElement):
    login_page_title = 'Login'
    
    username_txt = (By.XPATH, '//input[@placeholder="username"]')
    password_txt = (By.XPATH, '//input[@placeholder="password"]')
    
    login_btn = (By.XPATH, '//input[@class="login_button"]')
    
    first_name_txt = (By.XPATH, '//input[@placeholder="first name*"]')
    last_name_txt = (By.XPATH, '//input[@placeholder="last name*"]')
    email_txt = (By.XPATH, '//input[@placeholder="email*"]')
    phone_txt = (By.XPATH, '//input[@placeholder="phone"]')
    visiting_txt = (By.XPATH, '//input[@placeholder="visiting*"]')
    reason_txt = (By.XPATH, '//input[@placeholder="reason"]')

    register_btn = (By.XPATH, '//input[@class="reg_button"]')


class LoginPageAmigopod(WebElement):
    login_page_title = 'amigopod ::'
    
    username_txt = (By.XPATH, '//input[@name="username"]')
    password_txt = (By.XPATH, '//input[@name="password"]')
    
    login_btn = (By.XPATH, '//input[@value="Log In"]')


class LoginPageRegistration123(WebElement):
    login_page_title = 'Login'
    
    first_name_txt = (By.XPATH, '//input[@id="field1"]')
    last_name_txt = (By.XPATH, '//input[@id="field2"]')
    email_txt = (By.XPATH, '//input[@id="field3"]')
    visiting_txt = (By.XPATH, '//input[@id="field4"]')

    register_btn = (By.XPATH, '//input[@type="submit"]') 

class LoginPageNPD(WebElement):
    login_page_title = 'login'
    
    username_txt = (By.XPATH, '//input[@name="username"]')
    password_txt = (By.XPATH, '//input[@name="password"]')
    login_btn = (By.XPATH, '//input[@name="Submit2"]')     
    
    logo_img = (By.XPATH, '//img[@src="NDP_Logo_1.jpg"]')     