# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class LoginPage(WebElement):
    login_page_title = 'Power Controller'
    
    username_txt = (By.NAME, 'Username')
    password_txt = (By.NAME, 'Password')
    
    submit_btn = (By.NAME, 'Submitbtn')

class OutletPage(WebElement):
    outlet_page_title = "Outlet Control  - Web Power Switch II"
    autoping_title = 'AutoPing  - Web Power Switch II'

    autoping_linktxt = (By.LINK_TEXT, 'AutoPing')
    logout_linktxt = (By.LINK_TEXT, 'Logout')
