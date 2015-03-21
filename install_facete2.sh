#!/bin/bash

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
