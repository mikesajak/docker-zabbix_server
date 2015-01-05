#!/bin/bash

if [ -f '/zabbix/initialized' ]; then
    echo "Zabbix is already initialized. Skip setup and run server."
    sleep 15 # give some time for mysql to startup
else
    echo "Initialize Zabbix - prepare config, DB etc. web server"
    
    INIT_DELAY=30
    echo "Waiting $INIT_DELAY seconds before init"
    sleep $INIT_DELAY
    
    #groupadd -r zabbix && useradd -r -g zabbix zabbix
    
    #cd /zabbix
    #wget http://repo.zabbix.com/zabbix/2.4/ubuntu/pool/main/z/zabbix/zabbix-server-mysql_${ZABBIX_VER}_amd64.deb
    #wget http://repo.zabbix.com/zabbix/2.4/ubuntu/pool/main/z/zabbix/zabbix-frontend-php_${ZABBIX_VER}_all.deb
    ##    && wget http://repo.zabbix.com/zabbix/2.4/ubuntu/pool/main/z/zabbix/zabbix-java-gateway_${ZABBIX_VER}_amd64.deb
    #wget http://repo.zabbix.com/zabbix/2.4/ubuntu/pool/main/z/zabbix/zabbix-agent_2.4.3-1+trusty_amd64.deb
    
    mkdir -p /var/log/dbconfig-common
    
    # Prepare zabbix mysql DB
    ./init-mysql.sh
    
    sed -i s/%MYSQL_ZABBIX_PASSWORD/$MYSQL_DB_ENV_MYSQL_ROOT_PASSWORD/ /etc/dbconfig-common/zabbix-server-mysql.conf
    sed -i s/%MYSQL_SERVER_ADDR/$MYSQL_DB_PORT_3306_TCP_ADDR/ /etc/dbconfig-common/zabbix-server-mysql.conf
    sed -i s/%MYSQL_SERVER_PORT/$MYSQL_DB_PORT_3306_TCP_PORT/ /etc/dbconfig-common/zabbix-server-mysql.conf
    
    echo Install zabbix server packages
    DEBIAN_FRONTEND=noninteractive dpkg -i /zabbix/*.deb
    echo Finished installing zabbix server packages
    
    ./init-schema.sh
    
    # prepare Apache to serve zabbix
    sed -i 's/post_max_size[[:space:]]*=.*/post_max_size = 16M/' /etc/php5/apache2/php.ini
    sed -i 's/max_execution_time[[:space:]]*=.*/max_execution_time = 300/' /etc/php5/apache2/php.ini
    sed -i 's/max_input_time[[:space:]]*=.*/max_input_time = 300/' /etc/php5/apache2/php.ini
    sed -i 's/;date.timezone[[:space:]]*=.*/date.timezone = UTC/' /etc/php5/apache2/php.ini
    mkdir -p /var/log/apache2
    
    # prepare zabbix php configuration
    cp /usr/share/zabbix/conf/zabbix.conf.php.example /etc/zabbix/zabbix.conf.php
    #       cp /usr/share/doc/zabbix-frontend-php/examples/zabbix.conf.php.example /etc/zabbix/zabbix.conf.php
    sed -i 's/DB\["DATABASE"\][[:space:]]*=.*/DB["DATABASE"] = "zabbix";/' /etc/zabbix/zabbix.conf.php
    sed -i 's/DB\["USER"\][[:space:]]*=.*/DB["USER"] = "zabbix";/' /etc/zabbix/zabbix.conf.php
    sed -i 's/DB\["PASSWORD"\][[:space:]]*=.*/DB["PASSWORD"] = "zabbix";/' /etc/zabbix/zabbix.conf.php 
    
    mkdir -p /var/log/zabbix-server
    chown zabbix:zabbix /var/log/zabbix-server
    
    touch /zabbix/initialized
fi

monit -d 10 -v -Ic /etc/monitrc
            