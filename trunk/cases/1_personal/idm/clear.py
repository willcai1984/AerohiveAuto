'''
Created on 2013-7-30

@author: ftan
'''
import time
from selenium import webdriver
import os
import random
import login,createAdminGroup,check,createUser,deleteAccount,home_customer,guestAccount,registrationUI,logAndEmail


def guestClear(url,loginName,loginPasswd,log):
    i=2
    browser=webdriver.Firefox()
    browser.maximize_window()
    browser.get(url)
    a=login.loginAndGoto(loginName,loginPasswd,browser,url,log)
    a.login()
    time.sleep(2)
    browser.find_element_by_xpath("/html/body/div/div[2]/div/div/ul/li[3]/a").click()
    time.sleep(2)
    try:
        browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div[2]/ul/li/a").click()
    except Exception:
        browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/ul/li/a").click()
    browser.refresh()
    while True:
        try:
#             browser.refresh()
            try:
                browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/div/form/div/div/table/tbody/tr["+str(i)+"]/td/input").click()
            except Exception:
                browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div[2]/div/form/div/div/table/tbody/tr["+str(i)+"]/td/input").click()
#                                                /html/body/div/div[2]/div[2]/div[2]/div/div/div/form/div/div/table/tbody/tr/td/input
#                                                /html/body/div/div[2]/div[2]/div[2]/div/div[2]/div/form/div/div/table/tbody/tr/td/input
        except Exception:
            break
        i=i+1
    try:
        browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div[2]/div/form/div/ul/li[5]/a").click()
    except Exception:
        browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/div/form/div/ul/li[5]/a").click()
    time.sleep(2)
    browser.find_element_by_xpath("/html/body/div[3]/div/div/div/p[2]/a").click()
    browser.refresh()
    try:
        browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div[2]/ul/li[2]/a").click()
    except Exception:
        browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/ul/li[2]/a").click()
    browser.refresh()
    
    while True:
        try:
            browser.refresh()
            browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/div/div/form/div/table/tbody/tr[3]/td/input").click()
#                                            /html/body/div/div[2]/div[2]/div[2]/div/div/div/form/div/div/table/tbody/tr[4]/td/input
#                                            /html/body/div/div[2]/div[2]/div[2]/div/div[2]/div/form/div/div/table/tbody/tr[4]/td/input

        except Exception:
            break
        
        log.write("select admin group,")
        try:
            
            browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div[2]/div/form/div/ul/li[3]/a").click()
        except Exception :
            
            browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/div/div/form/ul/li[3]/a").click()
        time.sleep(1)
        log.write("click remove")
        browser.find_element_by_xpath("/html/body/div[3]/div/div/div/p[2]/a").click()
    browser.close()

def adminClear(url,loginName,loginPasswd,log):
    i=2
    browser=webdriver.Firefox()
    browser.maximize_window()
    browser.get(url)
    a=login.loginAndGoto(loginName,loginPasswd,browser,url,log)
    a.login()
    time.sleep(2)
    browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/ul/li/a").click()
    time.sleep(1)
#     browser.find_element_by_xpath("/html/body/div/div[2]/div/div/ul/li[3]/a").click()
#     /html/body/div/div[2]/div[2]/div[2]/div/div/div/form/div/div/table/tbody/tr/td
# /html/body/div/div[2]/div[2]/div[2]/div/div/div/form/div/div/table/tbody/tr/td/input
    while True:
        try:
#             browser.refresh()
            browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/div/form/div/div/table/tbody/tr["+str(i)+"]/td/input").click()
        except Exception:
            break
        i=i+1
    log.write("select account")
    browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/div/form/div/ul/li[3]/a").click()
    log.write("click remove")
    browser.find_element_by_xpath("/html/body/div[3]/div/div/div/p[2]/a").click()
    time.sleep(2)
    browser.refresh()
    try:
        
        browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div[2]/ul/li[2]/a").click()
    except Exception:
        browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/ul/li[2]/a").click()
                                   
                                 
    time.sleep(1)
#     /html/body/div/div[2]/div[2]/div[2]/div/div[2]/div/form/div/div/table/tbody/tr[3]/td/input
#     i=4
    while True:
        try:
            browser.refresh()
            browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/div/form/div/div/table/tbody/tr[4]/td/input").click()
#                                            /html/body/div/div[2]/div[2]/div[2]/div/div/div/form/div/div/table/tbody/tr[4]/td/input
#                                            /html/body/div/div[2]/div[2]/div[2]/div/div[2]/div/form/div/div/table/tbody/tr[4]/td/input
        except Exception:
            break
        
        log.write("select admin group,")
        try:
            
            browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div[2]/div/form/div/ul/li[3]/a").click()
        except Exception :
            browser.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/div/div/div/form/div/ul/li[3]/a").click()
        time.sleep(1)
        log.write("click remove")
        browser.find_element_by_xpath("/html/body/div[3]/div/div/div/p[2]/a").click()                                      
    browser.close()
    
if __name__=='__main__':
    url="https://10.155.34.182/idmanager"
    loginName="admin"
    loginPasswd="aerohive"
    log=logAndEmail.cteateLog()
    log.write("logstart:")
    adminClear(url,loginName,loginPasswd,log)
    loginName="alaizhu+718test1@hotmail.com"
    loginPasswd="aerohive"
    guestClear(url,loginName,loginPasswd,log)
    log.write("log end")
    sendEmail=logAndEmail.email("C:\\test"+log.fileName+".log","delete data")
    sendEmail.email()
    try:
        os.remove("C:\\test"+log.fileName+".log" )
    except  WindowsError:
        print "delete log fail"


    
        
    
    
    
    
