#!/bin/bash

echo Init Zabbix DB schema
MYSQL_CMD="mysql -h$MYSQL_PORT_3306_TCP_ADDR -p$MYSQL_PORT_3306_TCP_PORT -uzabbix -pzabbix"
SCRIPTS_DIR=/usr/share/zabbix-server-mysql
echo -- schema
$MYSQL_CMD zabbix < $SCRIPTS_DIR/schema.sql
echo -- images
$MYSQL_CMD zabbix < $SCRIPTS_DIR/images.sql
echo -- data
$MYSQL_CMD zabbix < $SCRIPTS_DIR/data.sql
echo Finished ininializing Zabbix DB schema

