'''
Created on 2013-7-10

@author: ftan
'''

import time
from selenium import webdriver

# def checkGroupAndUser(type,name,browser):
#     currentTitle=browser.title
#     if type==2:
#         browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/div[2]/div[2]/div/div/ul/li[2]/a").click()
#         time.sleep(2)
# #     browser.find_element_by_xpath("//table[@id='J-data-table']/tbody/a[@title='"+groupname+"']").click()
#         temp=browser.find_element_by_xpath("//a[@title='"+name+"']")
#     else:
#         browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/div[2]/div[2]/div/div/ul/li/a").click()
#         temp=browser.find_element_by_xpath("//span[@title='"+name+"']")
#         time.sleep(2)
#     return temp.text==name
class check:
    type=None
    name=None
    browser=None
    def checkGroupAndUser(self):
#         currentTitle=browser.title
        if self.type==2:
            print "2 :"
            print type
            self.browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/div[2]/div[2]/div/div/ul/li[2]/a").click()
            time.sleep(2)
#     browser.find_element_by_xpath("//table[@id='J-data-table']/tbody/a[@title='"+groupname+"']").click()
            temp=self.browser.find_element_by_xpath("//a[@title='"+self.name+"']").text
        elif type==1:
            print "1"
            print self.type
            self.browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/div[2]/div[2]/div/div/ul/li/a").click()
            temp=self.browser.find_element_by_xpath("//span[@title='"+self.name+"']").text
            time.sleep(2)
            
        else:
            temp=""
            print self.type
        return temp==self.name
    
    def changeTypeValue(self,type):
        self.type=type 
    
    def changeNameValue(self,name):
        self.name=name
    
    def __init__(self,type,name,browser):
        self.browser=browser
        self.type=type
        self.name=name