#!/bin/bash

if [ ! -s "$PGDATA/PG_VERSION" ]; then
echo "*:*:*:$PG_REP_USER:$PG_REP_PASSWORD" > ~/.pgpass

chmod 0600 ~/.pgpass

until ping -c 1 -W 1 ${PG_MASTER_HOST:?missing environment variable. PG_MASTER_HOST must be set}
    do
        echo "Waiting for master to ping..."
        sleep 1
done
until pg_basebackup -h ${PG_MASTER_HOST} -D ${PGDATA} -U ${PG_REP_USER} -vP -W
    do
        echo "Waiting for master to connect..."
        sleep 1
done

echo "host replication all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"

set -e

cat >> ${PGDATA}/postgresql.conf <<EOF
standby.signal = on
primary_conninfo = 'host=$PG_MASTER_HOST port=${PG_MASTER_PORT:-5432} user=$PG_REP_USER password=$PG_REP_PASSWORD'
promote_trigger_file = '/tmp/touch_me_to_promote_to_me_master'

hot_standby = on
max_standby_archive_delay = 30s
max_standby_streaming_delay = 30s

wal_receiver_timeout = 60s
wal_retrieve_retry_interval = 5s

hot_standby_feedback = on
EOF
chown postgres. ${PGDATA} -R
chmod 700 ${PGDATA} -R
fi

sed -i 's/wal_level = hot_standby/wal_level = replica/g' ${PGDATA}/postgresql.conf 

touch /var/lib/postgresql/data/standby.signal

exec "$@"
