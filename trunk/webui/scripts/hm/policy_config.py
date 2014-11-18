# -*- coding: UTF-8 -*
#policy_config.py -r http://{sta.ip}:4444/wd/hub -t ff -f LogFile --parameters policy.name=aaa_user_dir aaa_user_dir.name=new_aaa_ladp
#policy_config.py -r http://{sta.ip}:4444/wd/hub -t ff -f LogFile --parameters policy.name=user_profile user_profile.name=1_testb user_profile.attribute=2 user_profile.vlan=1

from webui import safe_call,WebUI
from webui.hm import HM
from webui.hm.configuration import Configuration

@safe_call
def policy_config():
    wui=WebUI()
    hm=HM()
    configer = Configuration()
    if wui.session_id is None:
        hm.login(wui.d("login.server"),
                 wui.d("login.username"),
                 wui.d("login.password"))
    for config_object in wui.d("policy.name").split(): 
    	configer.create_config(config_object)
    
if __name__ == '__main__':
    policy_config()    
    
