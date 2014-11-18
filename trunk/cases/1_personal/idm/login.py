'''
Created on 2013-7-10

@author: ftan
'''
from selenium import webdriver
import time



class loginAndGoto:
    loginName=None
    loginPasswd=None
    url=None
    browser=None
    log=None
    def login(self):
        print self.browser
#         print self.browser.title
        
#     abc=browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/h3/strong").text
#         self.log.write("login,")
        self.browser.find_element_by_xpath("//*[@id='username']").send_keys(self.loginName)
        self.log.write("login name : "+self.loginName)        
        self.browser.find_element_by_xpath("//*[@id='password']").send_keys(self.loginPasswd)
        self.log.write("login passwd : "+self.loginPasswd)
        self.browser.find_element_by_xpath("//form[@id='credentials']/div[2]/div/table/tbody/tr[4]/td[2]/input").click()
        self.log.write(" login.")
        time.sleep(2)
    def gotoidm_techOP(self):
        self.log.write("goto idm as techOP.")
        self.browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/div/div[2]/div/div[2]/a").click()
    
    def gotoidm_customer(self):
        self.log.write("goto idm as customer ")
        self.browser.find_element_by_xpath("/html/body/div[3]/div[2]/div/div[2]/div[2]/div[2]/a").click()
    
    

    def __init__( self ,loginName,loginPasswd,browser,url,log):
        self.loginName=loginName
        self.loginPasswd=loginPasswd
        self.browser=browser
        self.url=url
        self.log=log
        
     
# def login(name,passwd,url,browser):
#     
#     browser.get(url)
# #     abc=browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/h3/strong").text
#     browser.find_element_by_xpath("//*[@id='username']").send_keys(name)        
#     browser.find_element_by_xpath("//*[@id='password']").send_keys(passwd)
#     browser.find_element_by_xpath("//form[@id='credentials']/div[2]/div/table/tbody/tr[4]/td[2]/input").click()
#     time.sleep(2)
#  
# def gotoidm(browser):
    
#     browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/div/div[2]/div/div[2]/a").click()    
