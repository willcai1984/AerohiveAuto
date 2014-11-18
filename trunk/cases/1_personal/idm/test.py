'''
Created on 2013-7-10

@author: ftan
'''

import time
import os
from selenium import webdriver
import selenium
import login,createAdminGroup,check,createUser,deleteAccount,logAndEmail
import traceback


if __name__=='__main__':
#     selenium.selenium.
    loginName="admin"
    loginPasswd="aerohive"
    url="https://10.155.34.185"
    privileges=["monitor_read","usergroup_write"]
    groupName="group"+time.strftime("%Y-%m-%d %H:%M:%S")
    description="test"
    userName="user"+time.strftime("%Y-%m-%d %H:%M:%S")
    email="tanfei2+"+time.strftime("%Y%m%d%H%M%S")+"@hotmail.com"
    language="English"
    type=2
    # type=1----------useraccount,type=2---------admingroup
#     try:
#     browser2=webdriver.Ie()
    browser=webdriver.Firefox()
#     browser=selenium("localhost", 4444, "*firefox", "https://10.155.34.18")
#     browser.start()
#     browser= webdriver.Remote( browser_name="firefox")
    browser.maximize_window()
    browser.get(url)
#     except Exception as k:
#         print str(k)
    time.sleep(2)
    log=logAndEmail.cteateLog()
    log.write("log start:")
    print browser.title
    try:
        
        log.write("login")
        a=login.loginAndGoto(loginName,loginPasswd,browser,url,log)
        a.login()
        a.gotoidm_techOP()
        log.write("create admin group")
        b=createAdminGroup.createAdminGroup(groupName,description,privileges,browser,log)
        b.createAdminGroup()
# c=check.check(type,groupName,browser)
# print c.type
# print c.type==2
# print c.checkGroupAndUser()
        log.write("create admin user")
        d=createUser.createUser(email,userName,groupName,description,language,browser,log)
        d.createUser()
# c.changeNameValue(userName)
# c.changeTypeValue(1)
# print c.checkGroupAndUser()
#         log.write("delete created admin group and user")
#         e=deleteAccount.deleteAccount(userName,email,description,browser,log)
#         e.deleteAccount()
        browser.close()
        log.write("log end")
        
    except Exception as e:
        log.write(str(e))
    sendEmail=logAndEmail.email("C:\\test"+log.fileName+".log","create admin type and admin group")
    sendEmail.email()
    try:
        os.remove("C:\\test"+log.fileName+".log" )
    except  WindowsError:
        print "delete log fail"

