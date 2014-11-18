#!/usr/bin/python

import argparse, sys, re

parser = argparse.ArgumentParser(description='all lines in source file should be found in target file')

parser.add_argument('-s', '--source', required=True, dest='source',
                    help='source file')

parser.add_argument('-t', '--target', required=True, dest='target',
                    help='target file')

if __name__ == '__main__':
	args = parser.parse_args()
	
	print 'source file: %s' % args.source
	print 'target file: %s' % args.target
	print ''
	
	fs = None
	ft = None
	
	ret = True
	
	try:
		fs = open(args.source, 'r')
		ft = open(args.target, 'r')
	except:
		print 'error occurred:', sys.exc_info()[1]
		sys.exit(2)
	else:
		for ls in fs:
			found = False
			ls = ls.lower().strip()
			ft.seek(0)
			for lt in ft:
				lt = lt.lower().strip()
				if ls.replace(' ','') == lt.replace(' ',''):
					found = True
					break
			if found:
				print 'found: ' + ls
			else:
				print 'no: ' + ls
				if ret: ret = False

		print ''
		if ret:
			print 'success'
			sys.exit(0)
		else:
			print 'fail'
			sys.exit(1)
	finally:
			if fs:
				try:
					fs.close()
				except:
					pass
			if ft:
				try:
					ft.close()
				except:
					pass
				
