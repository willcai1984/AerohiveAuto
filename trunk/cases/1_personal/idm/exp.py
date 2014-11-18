'''
Created on 2013-7-11

@author: ftan
'''
# from idm import logAndEmail
# # import paramiko
# 
# class test:
# 
#     a=None
#     b=None
#     def __init__(self,a,b):
#         self.a=a
#         self.b=b
#     def output(self):
#         print self.a
#         print self.b 
        


# if __name__=='__main__':
#     log=logAndEmail.cteateLog()
#     log.write("start")
#     try:
#         print adb
#     except Exception as e:
#         print e
#         log.write(str(e))
        
    # -*- coding: utf-8 -*-

# import poplib
# from email import parser
# 
# host = 'pop.aerohive.com'
# username = 'ftan@aerohive.com'
# password = '555686868_tf'
# 
# pop_conn = poplib.POP3_SSL(host)
# pop_conn.user(username)
# pop_conn.pass_(password)
# 
# #Get messages from server:
# messages = [pop_conn.retr(i) for i in range(1, len(pop_conn.list()[1]) + 1)]
# 
# # Concat message pieces:
# messages = ["\n".join(mssg[1]) for mssg in messages]
# 
# #Parse message intom an email object:
# messages = [parser.Parser().parsestr(mssg) for mssg in messages]
# for message in messages:
#     print message['Subject']
# pop_conn.quit()

import abcdd
# from idm import logAndEmail
# import time
# import os, sys, string
# import poplib
# 
# 
# host = "pop3.live.com"
# 
# username = "tanfei2@hotmail.com"
# 
# password = "555686868_tF"
# 
# pp = poplib.POP3(host)
# 
# pp.set_debuglevel(1)
# 
# pp.user(username)
# 
# pp.pass_(password)
# 
# # ret = pp.stat()
# # print ret
# # 
# # for i in range(1, ret[0]+1):
# #     
# #     mlist = pp.top(i, 0)
# #     print 'line: ', len(mlist[1])
# # 
# # ret = pp.list()
# # print ret
# 
# down = pp.retr(1)
# print 'lines:', len(down)
# 
# for line in down[1]:
#     print line

# pp.quit()
