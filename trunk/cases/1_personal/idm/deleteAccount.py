'''
Created on 2013-7-10

@author: ftan
'''
import time
from selenium import webdriver
import check
# def deleteAccount(userName,email,description,browser):
#     
#     browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/div[2]/div[2]/div/div/ul/li/a").click()
#     time.sleep(2)
#     browser.find_element_by_xpath("//input[@data-id='"+email+"']").click()
#     browser.find_element_by_xpath("//form[@id='userList']/div/ul/li[3]/a").click()
#     time.sleep(2)
#     browser.find_element_by_xpath("/html/body/div[3]/div/div/div/p/a").click()
#     time.sleep(4)
# #     print check.checkGroupAndUser(1, userName, browser)
# #     print check.checkGroupAndUser(2, description, browser)
#     time.sleep(4)
#     
#     browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/div[2]/div[2]/div/div/ul/li[2]/a").click()
#     time.sleep(2)
#     browser.find_element_by_xpath("//span[@title='"+description+"']").click()
#     browser.find_element_by_xpath("//form[@id='userGrpList']/div/ul/li[3]/a").click()
#     time.sleep(2)
#     browser.find_element_by_xpath("/html/body/div[3]/div/div/div/p/a").click()
#   
#     print "delete successfully"
# 
# #     result=(not check.checkGroupAndUser(1, userName, browser)) and (not check.checkGroupAndUser(2, description, browser))
# #     print result
# #     return result

class deleteAccount:
    userName=None
    email=None
    description=None
    browser=None
    log=None
    
    def deleteAccount(self):
    
        self.log.write("click 'admin accounts'")
        self.browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/div[2]/div[2]/div/div/ul/li/a").click()
        time.sleep(2)
        self.log.write("select a record ,it's email address is "+self.email)
        self.browser.find_element_by_xpath("//input[@data-id='"+self.email+"']").click()
        self.browser.find_element_by_xpath("//form[@id='userList']/div/ul/li[3]/a").click()
        time.sleep(2)
        self.log.write("click 'remove'")
        self.browser.find_element_by_xpath("/html/body/div[3]/div/div/div/p/a").click()
        time.sleep(4)
#         print check.checkGroupAndUser(1, userName, browser)
#         print check.checkGroupAndUser(2, description, browser)
        time.sleep(4)
    
        self.log.write("click 'admin group'")
        self.browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/div[2]/div[2]/div/div/ul/li[2]/a").click()
        time.sleep(2)
        self.log.write("select a record ,it's description is " + self.description)
        self.browser.find_element_by_xpath("//span[@title='"+self.description+"']").click()
        self.browser.find_element_by_xpath("//form[@id='userGrpList']/div/ul/li[3]/a").click()
        time.sleep(2)
        self.log.write("click 'remove'")
        self.browser.find_element_by_xpath("/html/body/div[3]/div/div/div/p/a").click()
      
        print "delete successfully"
    def __init__(self,userName,email,description,browser,log):
        self.userName=userName
        self.email=email
        self.description=description
        self.browser=browser
        self.log=log
        
        
