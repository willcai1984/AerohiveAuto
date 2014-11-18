'''
Created on 2013-7-12

@author: ftan
'''


import time
from selenium import webdriver
from selenium.webdriver.support.ui import Select
from selenium.common import exceptions

# basicURL="https://idmanager-beta.aerohive.com/idmanager/register/welcome"

class gotoRegistrationUI:
    basicURL="https://10.155.34.182/idmanager/register/login"
    browser=None
    tempStr=None
    guestType=None
    tempList=["welcome","login","logout"]
    condition=None
    firstName=None
    lastName=None
    email=None
    purpose=None
    log=None
    def welcomPage(self):
        self.browser=webdriver.Firefox()
        self.browser.maximize_window()
        self.browser.get(self.basicURL)
#         temp=self.browser.find_element_by_xpath("/html/body/form/div/div[2]/div/table/tbody/tr/td/div/div").text
#         temp=self.browser.find_element_by_xpath("/html/body/div/div[2]/div/table/tbody/tr[2]/td/div/div/div/h2").text
#         /html/body/div/div[2]/div/table/tbody/tr[2]/td/div/div/div/h2
        self.tempStr=self.browser.current_url
        for temp in self.tempList:
#             try:
#                 print self.tempStr.index("welcome")
#             except ValueError:
#                 continue
#             break
            if self.tempStr.find(temp)!=-1 :
                self.condition=temp
                break;
            else:
                pass
        if self.condition==None:
            pass
        elif self.condition=="welcome":
            pass
        elif self.condition=="login":
            pass
        elif self.condition=="logout":
            pass
        else:
            pass
        
    def registerOneGuest(self):
#         /html/body/form/div/div[2]/div/table/tbody/tr[2]/td/div/div/table/tbody/tr[2]/td/div/div/a/img
        self.log.write("click 'register a guest'")
        time.sleep(2)
        self.browser.find_element_by_xpath("/html/body/form/div/div[2]/div/table/tbody/tr[2]/td/div/div/table/tbody/tr[2]/td/div/div/a/img").click()
        time.sleep(2)
        self.log.write("select a guesttype, the guesttype is"+self.guestType)
        self.browser.find_element_by_xpath("//img[@title='"+self.guestType+"']").click()
        time.sleep(2)
        self.log.write("input firstname :"+self.firstName)
        self.browser.find_element_by_xpath("//*[@id='firstname']").send_keys(self.firstName)
        self.log.write("input lastname :"+self.lastName)
        self.browser.find_element_by_xpath("//*[@id='lastname']").send_keys(self.lastName)
        self.log.write("input email :"+self.email)
        self.browser.find_element_by_xpath("//*[@id='email']").send_keys(self.email)
        self.log.write("click 'nest'")
        self.browser.find_element_by_xpath("/html/body/form/div/div/div/div[3]/a[2]/img").click()
        time.sleep(2)
        self.log.write("click 'confirm'")
        self.browser.find_element_by_xpath("/html/body/form/div/div/div/div[3]/a[2]/img").click()
        time.sleep(2)
        self.log.write("select type of sending guest email")
        self.browser.find_element_by_xpath("/html/body/form/div/div/div/div[2]/div/table/tbody/tr/td[2]/div/a/img").click()
        self.log.write("click 'send'")
        self.browser.find_element_by_xpath("//*[@id='nextsetup']").click()
        time.sleep(2)
        self.log.write("click 'comfirm'")
        self.browser.find_element_by_xpath("/html/body/div[3]/div/table/tbody/tr[2]/td/div[2]/a/img").click()
        time.sleep(8)
        self.log.write("click 'done'")
#         self.browser.find_element_by_xpath("/html/body/form/div/div/div/div[3]/div[2]/div/a/img").click()
#                                             /html/body/form/div/div/div/div[3]/div[2]/div/a/img
#                                             /html/body/form/div/div/div/div[3]/div[2]/div/a/img
#                                             /html/body/form/div/div/div/div[3]/div[2]/div/a/img
        time.sleep(2)
        self.browser.close()

    def registerOneGroup(self):    
        time.sleep(2)
        self.log.write("click 'register a group'")
        self.browser.find_element_by_xpath("/html/body/form/div/div[2]/div/table/tbody/tr[2]/td/div/div/table/tbody/tr[2]/td/div[2]/div/a/img").click()  
         
        time.sleep(2)
        self.log.write("select guesttype :"+self.guestType)
        self.browser.find_element_by_xpath("//img[@title='"+self.guestType+"']").click()   
        time.sleep(2)
        self.log.write("input purpose :"+self.purpose)
        self.browser.find_element_by_xpath("//*[@id='purposeText']").send_keys(self.purpose)
        self.log.write("click 'next'")
        self.browser.find_element_by_xpath("/html/body/form/div/div/div/table/tbody/tr[3]/td/div/div[2]/div/a/img").click()
        time.sleep(2)
#         add a guest (can add many guests by the buttom )
        self.log.write("input guest info")
        self.browser.find_element_by_xpath("//*[@id='addname']").send_keys("test")
        self.browser.find_element_by_xpath("//*[@id='addcontact']").send_keys("tanfei2+12131@hotmail.com")
        self.browser.find_element_by_xpath("//*[@id='addimgbutton']").click()
        self.log.write("select type of sending guest : email")
        
#         self.browser.find_element_by_xpath("/html/body/form/div/div/div/table/tbody/tr[3]/td/div/div[2]/div/a").click()
        self.browser.find_element_by_xpath("/html/body/form/div/div/div/table/tbody/tr[3]/td/div/div[2]/div/a/img").click()
#                                         /html/body/form/div/div/div/div[2]/div/table/tbody/tr/td[2]/div/a/img
#                                             /html/body/form/div/div/div/div[2]/div/table/tbody/tr/td[2]/div/a/img
        self.log.write(" 1")
        time.sleep(3)
        self.browser.find_element_by_xpath("/html/body/form/div/div/div/div[2]/div/table/tbody/tr/td[2]/div/a/img").click()
#                                             /html/body/form/div/div/div/div[2]/div/table/tbody/tr/td[2]/div/a/img
#                                             /html/body/form/div/div/div/div[3]/div[2]/div/a/img
#                                             /html/body/form/div/div/div/div[3]/div[2]/div/a/img
#                                             /html/body/form/div/div/div/div[2]/div/table/tbody/tr/td[2]/div/a/img
        self.log.write("click 'next'")
#         self.browser.find_element_by_xpath("//*[@id='nextsetup']").click()
        self.browser.find_element_by_xpath("/html/body/form/div/div/div/div[3]/div[2]/div/a/img").click()
        self.log.write("input enail"+self.email)
        self.browser.find_element_by_xpath("//*[@id='toEmail']").send_keys(self.email)
        self.log.write("click 'create'")
        self.browser.find_element_by_xpath("/html/body/div[3]/div/table/tbody/tr[2]/td/div[2]/a/img").click()

        time.sleep(8)
        self.log.write("click 'done'")
#         self.browser.find_element_by_xpath("/html/body/form/div/div/div/div[3]/div[2]/div/a/img").click()
#                                               /html/body/div/div[2]/div[2]/div[2]/div/div/ul/li[2]/a
#                                               /html/body/form/div/div/div/div[3]/div[2]/div/a/img
        self.browser.close()

    def Kiosk(self):
        time.sleep(2)
        self.log.write("click 'kiosk'")
        self.browser.find_element_by_xpath("/html/body/form/div/div[2]/div/table/tbody/tr[2]/td/div/div/table/tbody/tr[2]/td/div[3]/div/a/img").click()
        self.log.write("click 'register as a guest'")
        time.sleep(4)
#         self.browser.find_element_by_xpath("/html/body/form/div/div[2]/div/div[2]/div[2]/a/img").click()
        self.browser.find_element_by_xpath("/html/body/form/div/div[2]/div/div[2]/div[2]/a/img").click()
        self.log.write("input firstname,lastname and email ,firstname: "+self.firstName+", lastname : "+self.lastName+", email: "+self.email)
        self.browser.find_element_by_xpath("//*[@id='firstname']").send_keys(self.firstName) 
        self.browser.find_element_by_xpath("//*[@id='lastname']").send_keys(self.lastName)
        self.browser.find_element_by_xpath("//*[@id='email']").send_keys(self.email)
#         self.browser.find_element_by_xpath()
        self.log.write("click 'next'")
        time.sleep(4)
        self.browser.find_element_by_xpath("/html/body/form/div/div/div/div[3]/a[2]/img").click()
        self.log.write("click 'comfirm'")
        time.sleep(4)
        self.browser.find_element_by_xpath("/html/body/form/div/div/div/div[3]/a[2]/img").click()
        self.log.write("click 'done'")
        time.sleep(8)
#         self.browser.find_element_by_xpath("/html/body/form/div/div/div/div[3]/a/img").click()
        time.sleep(2)
        self.browser.close()
        
        
    def __init__(self,guestType,firstName,lastName,email,purpose,loginName,loginPasswd,log): 
        self.guestType=guestType
        self.firstName=firstName
        self.lastName=lastName
        self.email=email
        self.log=log
        self.purpose=purpose
        self.browser=webdriver.Firefox()
        self.browser.maximize_window()
        self.log.write("goto registrationUI")
        self.browser.get(self.basicURL)
        self.log.write("login name is"+loginName+", passwd is "+loginPasswd)
        self.browser.find_element_by_xpath("//*[@id='username']").send_keys(loginName)
        self.browser.find_element_by_xpath("//*[@id='password']").send_keys(loginPasswd)
        self.log.write("click 'login'")
        self.browser.find_element_by_xpath("/html/body/form/div/div[2]/div/div[4]/a/img").click()
               
        
        
    
                
        
        
        