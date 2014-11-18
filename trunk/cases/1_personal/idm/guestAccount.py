'''
Created on 2013-7-12

@author: ftan
'''
import time
from selenium import webdriver
from selenium.webdriver.support.ui import Select
from selenium.common import exceptions

class createGuestType:
    
   
    userProfile=None
    guestType=None
    comments=None 
    browser=None
    log=None

    
    def createGuestType(self):
        self.log.write("click 'guesttype'")
        time.sleep(1)
        self.browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/ul/li[2]/a").click()
        time.sleep(2)
#         new a guest type
        self.log.write("click 'new'")
        self.browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/div/div/form/ul/li/a").click()
        time.sleep(4)
        self.log.write("guesttype name is"+self.guestType)
        self.browser.find_element_by_xpath("//*[@id='guestTypeName']").send_keys(self.guestType)
        self.log.write("select ssid ,the userprofile of ssid is "+self.userProfile)
        self.browser.find_element_by_xpath("//*[@id='J-ssid']").click()
        time.sleep(1)
#         userProfile=Attribute Number
        self.browser.find_element_by_xpath("//*[@id='J-ssid']").send_keys("tf-ppsk")
#         self.browser.find_element_by_xpath("//li[@data-userprofile='"+self.userProfile+"']").click()
#         select = Select(self.browser.find_element_by_xpath("/html/body/ul")) 
#         select.select_by_visible_text(self.groupname)
        self.log.write("description is ")
        self.browser.find_element_by_xpath("//*[@id='description']").send_keys("")
        self.log.write("click 'cteate'")
        self.browser.find_element_by_xpath("//*[@id='J-create']").click()
        time.sleep(4)
        
        
        
    
    def __init__(self,browser,guestType,userProfile,log):
        self.browser=browser
        self.guestType=guestType
        self.userProfile=userProfile
        self.log=log
        
        
        
class createUserAccount:
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
    guestloginName=None
    guestpasswd=None
    accessTime=None
    sendEmail=None
    guestSsid=None
    log=None
    
    def gotoCreateGuest(self):
        self.log.write("click 'guest accounts'")
        self.browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/ul/li/a").click()
        time.sleep(2)
        self.log.write("click 'new'")
        self.browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/div/form/div/ul/li/a").click()
        time.sleep(2)
        
    def createGuest(self):
#         self.gotoCreateGuest(self)
#         self.browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div/div[2]/div/div/p[2]/a").click()
        time.sleep(2)
        self.log.write("guetname is "+self.guestName)
        self.browser.find_element_by_xpath("//*[@id='guestName']").send_keys(self.guestName)
        self.log.write("organization is" +self.organization)
        self.browser.find_element_by_xpath("//*[@id='organization']").send_keys(self.organization)
        self.log.write("purpose is"+self.purposeOfVisit)
        self.browser.find_element_by_xpath("//*[@id='visitPurpose']").send_keys(self.purposeOfVisit)
        self.log.write("email is "+self.email)
        self.browser.find_element_by_xpath("//*[@id='email']").send_keys(self.email)
        self.log.write("phone is" +self.phone)
        self.browser.find_element_by_xpath("//*[@id='phoneNumber']").send_keys(self.phone)
        self.log.write("the type of logname is"+self.loginName)
        self.browser.find_element_by_xpath("//input[@value='"+self.loginName+"']").click()
#         logname:email,phone,name
        self.log.write("select guesttype" +self.guestType)
        select = Select(self.browser.find_element_by_xpath("//*[@id='J-guest-type']")) 
        select.select_by_visible_text(self.guestType)
        self.log.write("click 'create'")
        self.browser.find_element_by_xpath("//*[@id='J-next']").click()
#         guestSsid=self.browser.find_elenment_by_xpath("//form[@id='new-gt-form']/fieldset[3]/table/tbody/tr[2]/td[2]/p[2]/span").text
#         self.browser.find_element_by_xpath("//form[@id='new-gt-form']/fieldset[3]/table/tbody/tr[4]/td[2]/p/a").click()
        
#         self.guestloginName=self.browser.find_element_by_xpath("/html/body/div[6]/div/div/form/fieldset/table/tbody/tr[2]/td[2]/p").text
#         self.guestpasswd=self.browser.find_element_by_xpath("/html/body/div[6]/div/div/form/fieldset/table/tbody/tr[3]/td[2]/p").text
#         self.accessTime=self.browser.find_element_by_xpath("/html/body/div[6]/div/div/form/fieldset/table/tbody/tr[4]/td[2]/p").text
#         self.sendEmail=self.browser.find_element_by_path("//*[@id='deliver-name']").text  
        time.sleep(2)
        self.log.write("click 'confirm'")
        self.browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/form/fieldset[2]/table/tbody/tr[3]/td[2]/p/a").click()
                                                 
#         self.browser.find_element_by_xpath("/html/body/div[6]/div/div/form/fieldset[2]/table/tbody/tr[3]/td[2]/p/a").click()
        time.sleep(2)
    
    
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


class check:
    guestAccount=None
    guestType=None
    browser=None
    emil=None
    
    def checkGuestType(self):
        try:
            temp=self.browser.find_element_by_xpath("//a[@title='"+self.guestAccount+"']").text
        except exceptions.WebDriverException:
            print "guest type create fail!"
            return False
        return True

    def checkGuest(self):
        try:
            temp=self.browser.find_element_by_xpath("//a[@title='"+self.emil+"']").text
        except exceptions.WebDriverException:
            print "guest account create fail!"
            return False
        return True
    
    def __init__(self,browser,guestAccount,guestType,emil):
        self.guestAccount=guestAccount
        self.browser=browser
        self.guestType=guestType
        self.emil=emil
        
class bulkCreateGuestAccount:
    guestNamePefix=None
    guestNumber=None
    guestType=None
    browser=None
    email=None
    log=None
    guestinfo=["guest info:"]
    
    def __init__(self,guestNamePefix,guestnumber,guestType,email,browser,log):
        self.guestNamePefix=guestNamePefix
        self.guestNumber=guestnumber
        self.guestType=guestType
        self.browser=browser
        self.email=email
        self.log=log
        
    def bulkCreate(self):
        self.log.write("namepefix id" +self.guestNamePefix)
        self.browser.find_element_by_xpath("//*[@id='guestName']").send_keys(self.guestNamePefix)
        self.browser.find_element_by_xpath("//*[@id='userProfile']").clear()
        self.log.write("guestnumber is"+self.guestNumber)
        self.browser.find_element_by_xpath("//*[@id='userProfile']").send_keys(self.guestNumber)
        self.log.write("select guest type,guest type is"+self.guestType)
        select = Select(self.browser.find_element_by_xpath("//*[@name='authType']")) 
        select.select_by_visible_text(self.guestType)
        time.sleep(2)
#         //*[@id="J-create"]
        self.log.write("click 'create'")
        self.browser.find_element_by_xpath("//a[@id='J-create']").click()
        time.sleep(2)
        self.guestinfo.append("Wi-Fi Network:")
        self.guestinfo.append(self.browser.find_element_by_xpath("//form[@id='guest-two-form']/fieldset/table/tbody/tr/td[2]/p").text)
        self.guestinfo.append("Prefix for Guest Names:")
        self.guestinfo.append(self.browser.find_element_by_xpath("//form[@id='guest-two-form']/fieldset/table/tbody/tr[2]/td[2]/p").text)
        self.guestinfo.append("Number of Guests:")
        self.guestinfo.append(self.browser.find_element_by_xpath("//form[@id='guest-two-form']/fieldset/table/tbody/tr[3]/td[2]/p").text)
        self.guestinfo.append("Access Duration:")
        self.guestinfo.append(self.browser.find_element_by_xpath("//form[@id='guest-two-form']/fieldset/table/tbody/tr[4]/td[2]/p").text)
        self.browser.find_element_by_xpath("//*[@id='deliver-name']").send_keys(self.email)
        self.log.write("click 'comfirm'")
        self.browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/form/fieldset[2]/table/tbody/tr[3]/td[2]/p/a").click()
        time.sleep(2)
    def gotoBulkCreate(self):
        time.sleep(2)
        self.log.write("click 'guest accounts'")
        self.browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/ul/li/a").click()
        time.sleep(2)
        self.log.write("click 'bulk'")
        self.browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/div/form/div/ul/li[2]/a").click()
        time.sleep(2)
        