'''
Created on 2013-7-15

@author: ftan
'''
from selenium import webdriver
import os, sys, string
import poplib
import time
from selenium.common import exceptions
import logging
import smtplib
from email.mime.text import MIMEText

class log:
    logger=None
    file=None
    formatter=None    
    def clearOldLog(self):
        os.remove("C:\\test.log")
        
    def startLog(self):
        
        self.formatter = logging.Formatter("%(asctime)s %(levelname)s %(message)s")  
        self.file.setFormatter(self.formatter)
        self.logger.setLevel(logging.NOTSET)   
        
    def __init__(self):
        self.logger = logging.getLogger()
        self.file = logging.FileHandler("C:\\test.log")  
        self.logger.addHandler(file)
        

class email:
    fromaddr=None
    toaddrs=None
    username=None
    password=None
    msg=None
    server=None
    temp=None
    fileName=None
    emailName=None
    def __init__(self,fileName,emailName):
        self.fileName=fileName
        self.fromaddr = "ftan@aerohive.com"
        self.toaddrs  = "ftan@aerohive.com"
        self.username = "ftan"
        self.password = "555686868_tf"
        self.emailName=emailName
        fileHandle = open ( fileName ) 
        self.temp=str(fileHandle.read()) 
        fileHandle.close() 
        self.msg = MIMEText("logs:\n"+self.temp)
        self.msg["Subject"] = self.emailName
        self.msg["From"] = "ftan@aerohive.com"
        self.msg["To"] = "ftan@aerohive.com"
# msg = MIMEText("log:   "+temp)
# msg = MIMEText('aaa')
# The actual mail send
        self.server = smtplib.SMTP("mail.aerohive.com")
        
    
    
    
    def email(self):
        self.server.starttls()
        self.server.login(self.username,self.password)
        self.server.sendmail(self.fromaddr, self.toaddrs, self.msg.as_string())
        self.server.quit()
        
        
class cteateLog:
    text=None
    fileName=None
    def __init__(self):
        
        self.fileName=time.strftime("%Y%m%d%H%M%S")
    def write(self,text):
        self.text=text
        fileHandle = open ( 'C:\\test'+self.fileName+'.log','a') 
        fileHandle.write ( "\n"+time.strftime("%Y-%m-%d %H:%M:%S \t")+self.text ) 
        fileHandle.close()  
        
class readEmail:
    host=None
    username=None
    password=None
    pp=None
    rat=None
    def __init__(self):
        self.host = "pop3.live.com"
        self.username = "tanfei2@hotmail.com"
        self.password = "555686868_tF"
        
    def receive(self):
        self.pp = poplib.POP3(self.host)
        self.pp.set_debuglevel(1)
        self.pp.user(self.username)
        self.pp.pass_(self.password)
        self.ret = self.pp.stat()
        print self.ret
        for i in range(1, self.ret[0]+1):
            mlist = self.pp.top(i, 0)
            print 'line: ', len(mlist[1])
        ret = self.pp.list()
        print ret
        down = self.pp.retr(1)
        print 'lines:', len(down)
        for line in down[1]:
            print line


