################################################################################
# File Name: match.py
# Description: this script used to match the log no data
################################################################################
import os, time, sys, string, re
## this is match log file
matchfile = sys.argv[1]
## apneme of the testbed
apname = sys.argv[2]
## this is flag file to log match
##flagfile = sys.argv[3]

regular = '%sshow interface wifi0.1 _counter\s+\-+%s' % (apname, apname)
fileopen = open(matchfile)
##flagopen = open(flagfile, 'w')
data = fileopen.read()
data = data.replace('\r','').replace('\n','')
match = re.search(regular, data)
if match != None:
	sys.exit(0)
	print 'SUCCESS'
else:
	sys.exit(1)
	print 'FAIL'	