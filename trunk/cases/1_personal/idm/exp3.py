'''
Created on 2013-7-23

@author: ftan
'''
class WebUIArgs:
    
    def __init__(self):
        self.parser.add_argument('-r', '--remote-selenium', required=True, dest='remote_selenium',
                                 help='remote selenium url')