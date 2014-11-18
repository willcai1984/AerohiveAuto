# -*- coding: UTF-8 -*-


from webui import safe_call, WebUI
from webui.cloud import CLOUD

@safe_call
def cloud_to_url():
    wui = WebUI()
    cloud = CLOUD(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    cloud.to_url()
        
if __name__ == '__main__':
    cloud_to_url()
