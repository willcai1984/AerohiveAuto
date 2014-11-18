#!/bin/sh

staf 192.168.101.91 process start shell command "java -Xms512m -Xmx1024m -jar selenium-server-standalone-2.19.0.jar -log .\\logs\\selenium.log" workdir "d:\\webui" workload webui

sleep 5

export PYTHONPATH=/opt/auto_case
cd /opt/auto_case/webui
svn up
python test/test.py -r http://192.168.101.91:4444/wd/hub -t ie -f test

staf 192.168.101.91 process stop workload webui using sigkillall

tar cfz xxx.tgz test.html test_pic/

cd -