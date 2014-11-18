# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class LogoutPage(WebElement):
    logout_page_title = 'Logging out'
    
    left_session_time_td = (By.XPATH, '//td[contains(text(), "Left Session Time")]/../td[@width="311"]')
