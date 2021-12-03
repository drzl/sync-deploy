#! /bin/bash

mh='sync-f.{{ sync_int_dom }}'
slave_host='sync-f-db-clone.pvision'
mu='replication_user'
mp='{{ sync_mysql_pass_replica }}'
md='bpsync'

echo -n 'stopping slave... '
ssh "$slave_host" "echo 'stop slave;' | mysql -uroot; systemctl stop mariadb"
echo 'DONE'

rm -rf "/var/lib/mysql-clone"
mkdir "/var/lib/mysql-clone"

(
    echo 'reset master;'
    sleep 0.3
    echo 'flush tables with read lock;';
    sleep 0.3
    echo -n 'copy database dir... ' 1>&2
    cp --archive --reflink=auto "/var/lib/mysql" "/var/lib/mysql-clone/"
    echo 'DONE' 1>&2
    echo 'unlock tables;';
) | stdbuf -i0 -o0 mysql -uroot

echo 'sync database to slave...'
rsync -acz --delete --delete-excluded --no-whole-file --inplace --info=progress2 --stats "/var/lib/mysql-clone/mysql/" "$slave_host":"/var/lib/mysql/"
echo 'sync database to slave DONE'
rm -rf "/var/lib/mysql-clone"

echo -n 'starting slave... '
ssh "$slave_host" "systemctl start mariadb"
echo 'DONE'

echo -n 'configure slave... '
(
    echo 'stop slave;'
    echo 'reset slave;'
    echo "set global gtid_slave_pos = '1-1-0';"
    echo "change master to master_host='$mh', master_user='$mu', master_password='$mp', master_use_gtid=slave_pos, master_delay=0;"
    echo 'start slave;'
) | ssh "$slave_host" 'mysql -uroot'
echo 'DONE'
