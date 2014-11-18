#create right talbe dir
test -d /home/auto_table_script
if [ $? -eq 0 ]; then
    echo "/auto_table_script exist!"
else
    mkdir /auto_table_script
fi

#create HM backup image dir
test -d /home/auto_table_upgrade_image
if [ $? -eq 0 ]; then
    echo "/auto_table_upgrade_image exist!"
else
    mkdir /home/auto_table_upgrade_image
fi