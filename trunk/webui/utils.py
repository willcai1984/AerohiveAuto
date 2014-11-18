# -*- coding: UTF-8 -*-

from logging import FileHandler 
from cgi import escape
from unittest import TestCase
import os.path, sys

# Singleton pattern without thread safety
# 
# TODO:
# - thread safety?
class Singleton(type):
    _INSTANCES = {}

    def __call__(cls, *args, **kvargs):
        if cls not in cls._INSTANCES:
            cls._INSTANCES[cls] = super(Singleton, cls).__call__(*args, **kvargs)
        return cls._INSTANCES[cls]

# TODO:
# - improve representation of log file
class HtmlHandler(FileHandler, object):
    PIC_TAG = ' pic:'
    _PIC_TAG = 'ppic:'
    
    def __init__(self, filename):
        FileHandler.__init__(self, filename, mode='w', encoding=None, delay=0)
        self.stream.write('''<html>
    <head>
        <title>WebUI Log</title>
        <script language="javascript">
            function SetPicWidth(obj) {
                iMaxWidth = 800;
                iMinWidth = 100;
                iPicWidth = obj.width;
                if (iPicWidth == iMinWidth) {
                    obj.width = iMaxWidth;
                } else {
                    obj.width = iMinWidth;
                }
            }
        </script>
        <style type="text/css">
            div.debug {background-color:rgb(215,208,183); padding: 5px;}
            div.info {background-color:rgb(149,245,123); padding: 5px;}
            div.warning {background-color:rgb(252,252,142); padding: 5px;}
            div.error {background-color:rgb(253,143,135); padding: 5px;}
        </style>
    </head>
<body>
''')
    
    def format(self, record):
        msg = escape(record.msg).strip()
        msg = msg.replace(self.PIC_TAG, self._PIC_TAG).replace(' ', '&nbsp').replace('\n', '<br>')
        if self._PIC_TAG in msg:
            desc = msg.split(self._PIC_TAG)[0].strip()
            pic = msg.split(self._PIC_TAG)[1].strip()
            msg = '%s<br><img src="%s" OnClick="SetPicWidth(this);" width="100"/><br>' % (desc, pic)
        else:
            msg = '%s<br>' % msg
        record.msg = msg
        fmt = super(HtmlHandler, self).format(record)
        fmt = '<div class="%s">%s</div>' % (record.levelname.lower(), fmt)
        return fmt
    
    def close(self):
        self.stream.write('</body>\n</html>')
        FileHandler.close(self)

class AssertionHelper(TestCase):
    def __init__(self):
        TestCase.__init__(self, 'test_dummy')
        
    def test_dummy(self):
        raise Exception('this is just for using assertion functions')

def get_default_profile():
    return os.path.join(os.path.dirname(__file__), 'profile', 'ff')

def get_default_log_file():
    test = sys.argv[0]
    test_dir, test_file = os.path.split(test)
    return os.path.join(test_dir, 'WebUI.html')

def get_default_test_data():
    test = sys.argv[0]
    test_dir, test_file = os.path.split(test)
    return os.path.join(test_dir, '%s.json' % os.path.splitext(test_file)[0])

# TODO:
# - flexible filtering mechanism?
def json_value(json_obj, path):
    def _walk(json_obj, path):
        if path:
            current = path[0].strip()
            if current.endswith(']'):
                key, index = current.rstrip(']').split('[')
            else:
                key, index = current, None
            if key:
                json_obj = json_obj[key]
            if index:
                json_obj = json_obj[int(index)]
            return _walk(json_obj, path[1:])
        else:
            return json_obj
    return _walk(json_obj, path.split('.'))
