# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class CompanyPage(WebElement):
    company_page_title = 'Test'
    
    aerohive_img = (By.XPATH, '//img[@src="aerohive.gif"]')
