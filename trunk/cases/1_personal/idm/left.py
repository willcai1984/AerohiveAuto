'''
Created on 2013-7-12

@author: ftan
'''
from selenium import webdriver
from selenium.common import exceptions
class left:
    menuName=None
    browser=None
    location=None
    menuExist=None
    
    def checkMenuExists(self):
        i=2
        
        try:
            if self.browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div/ul/li/a").text==self.menuName :
                self.location=1
            else:
                pass
        except exceptions.WebDriverException:
                self.menuExist=False
        while 1==1:
            try:
                if self.browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div/ul/li["+str(i)+"]/a").test==self.menuName :
                    self.location=i
                    self.menuExist=True
                    break
                else:
                    i=i+1
                    continue
            except exceptions.WebDriverException:
                self.menuExist=False
                break
        

    def gotoMenu(self):
        if left.checkMenuExists(self) :
            self.browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div/ul/li["+str(self.location)+"]/a").click()
        else:
            print "menu can not be found! menuname:"+self.menuName
        
    
    def __init__(self,menuName,browser):
        self.menuName=menuName
        self.browser=browser