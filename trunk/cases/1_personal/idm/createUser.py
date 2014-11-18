'''
Created on 2013-7-10

@author: ftan
'''

import time
from selenium import webdriver
from selenium.webdriver.support.ui import Select

# def createUser(email,username,groupname,description,language,browser):
#     browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/div[2]/div[2]/div/div/ul/li/a").click()
#     time.sleep(2)
#     browser.find_element_by_xpath("//form[@id='userList']/div/ul/li/a").click()
#     time.sleep(2)
#     browser.find_element_by_xpath("//*[@id='userName']").send_keys(email)
#     browser.find_element_by_xpath("//*[@id='userFullName']").send_keys(username)
#     browser.find_element_by_xpath("//*[@id='description']").send_keys(description)
#     select = Select(browser.find_element_by_xpath("//*[@id='userGroup.id']")) 
#     select.select_by_visible_text(groupname)
#     time.sleep(2)
#     select2 = Select(browser.find_element_by_xpath("//*[@name='userSetting.language']")) 
#     select2.select_by_visible_text(language)
#     time.sleep(2)
#     browser.find_element_by_xpath("//*[@id='J-save']").click()
class createUser:
    email=None
    username=None
    groupname=None
    description=None
    language=None
    browser=None
    log=None
    def createUser(self):
        self.log.write("click 'admin account'")
        self.browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/div[2]/div[2]/div/div/ul/li/a").click()
        time.sleep(2)
        self.log.write("new a admin account")
        self.browser.find_element_by_xpath("//form[@id='userList']/div/ul/li/a").click()
        time.sleep(2)
        self.log.write("email address is"+self.email)
        self.browser.find_element_by_xpath("//*[@id='userName']").send_keys(self.email)
        self.log.write("username is "+self.username)
        self.browser.find_element_by_xpath("//*[@id='userFullName']").send_keys(self.username)
        self.log.write("description is "+self.description)
        self.browser.find_element_by_xpath("//*[@id='description']").send_keys(self.description)
        self.log.write("select admin group " + self.groupname)
        select = Select(self.browser.find_element_by_xpath("//*[@id='userGroup.id']")) 
        select.select_by_visible_text(self.groupname)
        time.sleep(2)
        self.log.write("select language  "+self.language)
        select2 = Select(self.browser.find_element_by_xpath("//*[@name='userSetting.language']")) 
        select2.select_by_visible_text(self.language)
        time.sleep(2)
        self.log.write("click 'create' ")
        self.browser.find_element_by_xpath("//*[@id='J-save']").click()
        
    def __init__(self,email,username,groupname,description,language,browser,log):
        self.email=email
        self.username=username
        self.groupname=groupname
        self.description=description
        self.language=language
        self.browser=browser
        self.log=log
        