'''
Created on 2013-7-16

@author: ftan
'''
import time
from selenium import webdriver
import os
import random
from idm import login,createAdminGroup,check,createUser,deleteAccount,home_customer,guestAccount,registrationUI,logAndEmail

if __name__=='__main__':
    
    loginName="alaizhu+718test1@hotmail.com"
    loginPasswd="aerohive"
    url="https://10.155.34.185"
    log=logAndEmail.cteateLog()
    log.write("logstart:")
    guestName="guest"+time.strftime("%Y-%m-%d %H:%M:%S")
    organization="test"
    purposeOfVisit="automation"
    email="tanfei2+"
    loginName2="email"
    guestType="guestType"+str(random.randint(0,999))

    comments="test"
    phone="11111111111"
    ssid="tf-ppsk"
#ssid's Attribute Number
    userProfile="4000"
    purpose="test"
    firstName="tf"
    lastName="tf"

    guestnumber=str(3)
    guestNamePefix="tf"

    browser=webdriver.Firefox()
    browser.maximize_window()
    browser.get(url)
    time.sleep(2)
    try:
        
        log.write("login")
        a=login.loginAndGoto(loginName,loginPasswd,browser,url,log)
        a.login()
        a.gotoidm_customer()


        customer=home_customer.home_customer(browser,guestName,organization,purposeOfVisit,email+str(random.randint(0,99999))+"@hotmail.com",loginName2,guestType,comments,phone,ssid,log)
        customer.gotoConfiguration()

# create guest type
        log.write("create guesttype")
        guesttype=guestAccount.createGuestType(browser,guestType,userProfile,log)
        guesttype.createGuestType()
#create a guest in configuration page
        log.write("create a guest")
        guestaccount=guestAccount.createUserAccount(browser,guestName,organization,purposeOfVisit,email+str(random.randint(0,99999))+"@hotmail.com",loginName2,guestType,comments,phone,ssid,log)
        guestaccount.gotoCreateGuest()
        guestaccount.createGuest()
#   
# #bulk create
        log.write("bulk create")
        guestaccount=guestAccount.bulkCreateGuestAccount(guestNamePefix,guestnumber,guestType,email+str(random.randint(0,99999))+"@hotmail.com",browser,log)
        guestaccount.gotoBulkCreate()
        guestaccount.bulkCreate()
#   
# create guest in home page
        log.write("create guestaccount in homepage")
        customer.gotoHome()
        customer.createGuest()
#   
# create a guest in reguistration UI
        log.write("create guestaccount in reguistrationUI")
        guestaccount=registrationUI.gotoRegistrationUI(guestType,firstName,lastName,email+str(random.randint(0,99999))+"@hotmail.com",purpose,loginName,loginPasswd,log)
        guestaccount.registerOneGuest()
#   
# create a group guest in reguistration UI
        guestaccount=registrationUI.gotoRegistrationUI(guestType,firstName,lastName,email+str(random.randint(0,99999))+"@hotmail.com",purpose,loginName,loginPasswd,log)
        guestaccount.registerOneGuest()
   
# create a guest by kiosk
        guestaccount=registrationUI.gotoRegistrationUI(guestType,firstName,lastName,email+str(random.randint(0,99999))+"@hotmail.com",purpose,loginName,loginPasswd,log)
        guestaccount.Kiosk()
        browser.close()
    except Exception as e:
        log.write(str(e))
    log.write("log end")
    sendEmail=logAndEmail.email("C:\\test"+log.fileName+".log","create guest type and guest account")
    sendEmail.email()
    try:
        os.remove("C:\\test"+log.fileName+".log" )
    except  WindowsError:
        print "delete log fail"

