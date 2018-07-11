#!/bin/bash
USER=${MONGODB_USERNAME:-mongo}
PASS=${MONGODB_PASSWORD:-$(pwgen -s -1 16)}
DB=${MONGODB_DBNAME:-admin}
if [ ! -z "$MONGODB_DBNAME" ]
then
    ROLE=${MONGODB_ROLE:-dbOwner}
else
    ROLE=${MONGODB_ROLE:-dbAdminAnyDatabase}
fi

# Start MongoDB service
/usr/bin/mongod --dbpath /data --nojournal &

# Create User
echo "Creating user: \"$USER\"..."
mongo $DB --eval "db.createUser({ user: '$USER', pwd: '$PASS', roles: [ { role: '$ROLE', db: '$DB' } ] });"
sed -i 's/bind_ip = 127.0.0.1/bind_ip = 0.0.0.0/g' /etc/mongodb.conf
sed -i '/Security:/d' /etc/mongod.conf
echo "security:" >> /etc/mongod.conf
echo '  authorization: "enabled"' >> /etc/mongodb.conf

# Stop MongoDB service
/usr/bin/mongod --dbpath /data --shutdown

echo "========================================================================" >> /root/.mongodb
echo "MongoDB User: \"$USER\"" >> /root/.mongodb
echo "MongoDB Password: \"$PASS\"" >> /root/.mongodb
echo "MongoDB Database: \"$DB\"" >> /root/.mongodb 
echo "MongoDB Role: \"$ROLE\"" >> /root/.mongodb
echo "========================================================================" >> /root/.mongodb
