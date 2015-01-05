docker run -d \
    -v /var/lib/mysql \
    -v /var/lib/zabbix \
    -v /etc/zabbix \
    -v /var/log \
    --name zabbix-data \
    debian \
    echo Data container for Zabbix
