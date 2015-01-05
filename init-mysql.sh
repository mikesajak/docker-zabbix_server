#!/bin/bash

env

# Prepare zabbix mysql DB
echo Prepare zabbix mysql DB
MYSQL_CMD="mysql -h$MYSQL_PORT_3306_TCP_ADDR -p$MYSQL_PORT_3306_TCP_PORT -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD"
echo -- create user
#$MYSQL_CMD -e "create user 'zabbix'@'$MYSQL_PORT_3306_TCP_ADDR' identified by 'zabbix';"
$MYSQL_CMD -e "create user 'zabbix'@'%' identified by 'zabbix';"
echo -- create DB
$MYSQL_CMD -e "create database zabbix;"
echo -- setup privileges
#$MYSQL_CMD -e "grant all privileges on zabbix.* to 'zabbix'@'localhost';"
$MYSQL_CMD -e "grant all privileges on zabbix.* to 'zabbix'@'%';"
echo -- flush
$MYSQL_CMD -e "flush privileges;"
echo Finished preparing zabbix mysql DB

