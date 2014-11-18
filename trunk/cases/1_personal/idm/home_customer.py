'''
Created on 2013-7-11

@author: ftan
'''
from selenium import webdriver
from selenium.webdriver.support.ui import Select
import time
import guestAccount

class home_customer:
    browser=None
    guestName=None
    organization=None
    purposeOfVisit=None
    email=None
    loginName=None
    guestType=None
    comments=None 
    phone=None
    ssid=None
#     the value recorded when create a guest
    guestloginName=None
    guestpasswd=None
    accessTime=None
    sendEmail=None
    guestSsid=None
    log=None
    
    
    
    def gotoMonitor(self):
        self.log.write("goto monitpr")
        self.browser.find_element_by_xpath("/html/body/div/div[2]/div/div/ul/li[2]/a").click()
    
    def gotoHome(self):
        self.log.write("goto home")
        self.browser.find_element_by_xpath("/html/body/div/div[2]/div/div/ul/li/a").click()
    
    
    def gotoConfiguration(self):
        self.log.write("goto configuration")
        self.browser.find_element_by_xpath("/html/body/div/div[2]/div/div/ul/li[3]/a").click()
        
    def gotoMyhive(self):
        self.log.write("goto myhive")
        self.browser.find_element_by_xpath("/html/body/div/div[2]/div/div/ul/li[4]/a").click()
    
    def gotoRegistrationUI(self):
        self.log.write("goto registrationUI")
        self.browser.find_element_by_xpath("/html/body/div/div[2]/div/div/ul/li[5]/a").click()
    
    def gotoGuestAccountmanagement(self):
        self.log.write("goto accountmenagement")
        self.browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div/div[2]/div/div/p[3]/a").click()

    def createGuest(self):
        self.log.write("create guestaccount in home page")
        time.sleep(2)
        self.browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div/div[2]/div/div/p[2]/a").click()
        time.sleep(2)
        self.log.write("guestname is "+self.guestName)
        self.browser.find_element_by_xpath("//*[@id='guestName']").send_keys(self.guestName)
        self.log.write("organization id "+self.organization)
        self.browser.find_element_by_xpath("//*[@id='organization']").send_keys(self.organization)
        self.log.write("purpose is "+self.purposeOfVisit)
        self.browser.find_element_by_xpath("//*[@id='visitPurpose']").send_keys(self.purposeOfVisit)
        self.log.write("email is "+self.email)
        self.browser.find_element_by_xpath("//*[@id='email']").send_keys(self.email)
        self.log.write("phone is"+self.phone)
        self.browser.find_element_by_xpath("//*[@id='phoneNumber']").send_keys(self.phone)
        self.log.write("chose loginnametype :"+self.loginName)
        self.browser.find_element_by_xpath("//input[@value='"+self.loginName+"']").click()
#         logname:email,phone,name
    
        self.log.write("select guesttype, guesttype is"+self.guestType)
        select = Select(self.browser.find_element_by_xpath("//*[@id='J-guest-type']")) 
        select.select_by_visible_text(self.guestType)
        time.sleep(2)
        self.log.write("click 'create'")
        self.browser.find_element_by_xpath("/html/body/div[4]/div/div/form/fieldset[3]/table/tbody/tr[4]/td[2]/p/a").click()
                                           
        
        self.log.write("click 'confirm'")
        time.sleep(4)
        self.browser.find_element_by_xpath("/html/body/div[5]/div/div/form/fieldset[2]/table/tbody/tr[3]/td[2]/p/a").click()
                                           
#         self.browser.find_element_by_xpath("//*[@id='guestName']").send_keys(self.guestName)
#         self.browser.find_element_by_xpath("//*[@id='organization']").send_keys(self.organization)
#         self.browser.find_element_by_xpath("//*[@id='visitPurpose']").send_keys(self.purposeOfVisit)
#         self.browser.find_element_by_xpath("//*[@id='email']").send_keys(self.email)
#         self.browser.find_element_by_xpath("//*[@id='phoneNumber']").send_keys(self.phone)
#         self.browser.find_element_by_xpath("//input[@value='"+self.loginName+"']").click()
# #         logname:email,phone,name
#     
#         select = Select(self.browser.find_element_by_xpath("//*[@id='J-guest-type']")) 
#         select.select_by_visible_text(self.guestType)
#         guestSsid=self.browser.find_elenment_by_xpath("//form[@id='new-gt-form']/fieldset[3]/table/tbody/tr[2]/td[2]/p[2]/span").text
#         self.browser.find_element_by_xpath("//form[@id='new-gt-form']/fieldset[3]/table/tbody/tr[4]/td[2]/p/a").click()
#         
#         self.guestloginName=self.browser.find_element_by_xpath("/html/body/div[6]/div/div/form/fieldset/table/tbody/tr[2]/td[2]/p").text
#         self.guestpasswd=self.browser.find_element_by_xpath("/html/body/div[6]/div/div/form/fieldset/table/tbody/tr[3]/td[2]/p").text
#         self.accessTime=self.browser.find_element_by_xpath("/html/body/div[6]/div/div/form/fieldset/table/tbody/tr[4]/td[2]/p").text
#         self.sendEmail=self.browser.find_element_by_path("//*[@id='deliver-name']").text       
#         self.browser.find_element_by_xpath("/html/body/div[6]/div/div/form/fieldset[2]/table/tbody/tr[3]/td[2]/p/a").click()
#         time.sleep(2)
    
    
    def __init__(self,browser,guestName,organization,purposeOfVisit,email,loginName,guestType,comments,phone,ssid,log):
        self.browser=browser
        self.guestName=guestName
        self.organization=organization
        self.purposeOfVisit=purposeOfVisit
        self.email=email
        self.loginName=loginName
        self.guestType=guestType
        self.comments=comments 
        self.phone=phone
        self.ssid=ssid
        self.log=log
