#!/bin/bash

# certificate workaround
mkdir /etc/ssl/private-copy
mv /etc/ssl/private/* /etc/ssl/private-copy/
rm -r /etc/ssl/private
mv /etc/ssl/private-copy /etc/ssl/private
chmod -R 0700 /etc/ssl/private
chown -R postgres /etc/ssl/private

service postgresql start

#apt-get -y install facete2-tomcat7
cd /build/Facete2/facete2-debian-tomcat-common/target/
dpkg -i *.deb
cd -

cd /build/Facete2/facete2-debian-tomcat7/target/
dpkg -i *.deb
cd -

service postgresql stop

exit 0
