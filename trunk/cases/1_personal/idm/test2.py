'''
Created on 2013-7-16

@author: ftan
'''
import time
from selenium import webdriver
from idm import login,createAdminGroup,check,createUser,deleteAccount,logAndEmail


loginName="admin"
loginPasswd="aerohive"
url="https://10.155.34.185"
privileges=["monitor_read","usergroup_write"]
groupName="group"+time.strftime("%Y-%m-%d %H:%M:%S")
description="test"
userName="user"+time.strftime("%Y-%m-%d %H:%M:%S")
email=time.strftime("%Y%m%d%H%M%S")+"@test.com"
language="English"
type=2
# type=1----------useraccount,type=2---------admingroup
browser=webdriver.Firefox()
browser.maximize_window()
browser.get(url)
time.sleep(2)
log=logAndEmail.log()
# log.clearOldLog()
log.startLog()
a=login.loginAndGoto(loginName,loginPasswd,browser,url)
a.login()
a.gotoidm()
b=createAdminGroup.createAdminGroup(groupName,description,privileges,browser)
b.createAdminGroup()
c=check.check(type,groupName,browser)
print c.type
print c.type==2
print c.checkGroupAndUser()
d=createUser.createUser(email,userName,groupName,description,language,browser)
d.createUser()
c.changeNameValue(userName)
c.changeTypeValue(1)
print c.checkGroupAndUser()
sendemail=logAndEmail.email()
sendemail.email()









