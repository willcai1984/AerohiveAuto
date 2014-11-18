# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class TestPage(WebElement):
    test_page_title = 'Test'
    
    aerohive_img = (By.XPATH, '//img[@sec="aerohive.gif"]')
