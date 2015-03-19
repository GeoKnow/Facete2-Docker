FROM ubuntu:14.04

MAINTAINER René Pietzsch <rpietzsch@gmail.com>

RUN export DEBIAN_FRONTEND=noninteractive

RUN echo "deb http://archive.ubuntu.com/ubuntu/ trusty main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ trusty-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update
RUN apt-get -y install postgresql supervisor wget openjdk-7-jdk dialog libterm-readline-gnu-perl git 
RUN apt-get -y install maven software-properties-common
RUN add-apt-repository -y ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get install -y nodejs

RUN apt-get install -qy apache2 libapache2-mod-proxy-html && \
	apt-get install -qy apache2-mpm-prefork apache2-utils  && \
	apt-get install -qy libapache2-mod-authnz-external

#dialog libterm-readline-gnu-perl
#RUN echo "deb http://cstadler.aksw.org/repos/apt precise main contrib non-free" > /etc/apt/sources.list.d/cstadler.aksw.org.list
#RUN wget -O - http://cstadler.aksw.org/repos/apt/conf/packages.precise.gpg.key | apt-key add -

#RUN echo "force-confold" >> /etc/dpkg/dpkg.cfg
#RUN echo "force-confdef" >> /etc/dpkg/dpkg.cfg
#RUN apt-get update

RUN mkdir /build
WORKDIR /build
RUN git clone https://github.com/GeoKnow/Facete2
WORKDIR /build/Facete2
RUN npm install -g bower grunt grunt-cli
RUN mvn package

ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
RUN ln -sf /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-available/000-default.conf

RUN wget -P /usr/share/tomcat7/lib/ http://repo1.maven.org/maven2/postgresql/postgresql/8.4-701.jdbc4/postgresql-8.4-701.jdbc4.jar
RUN wget -O /usr/share/java/tomcat-dbcp-7.0.30.jar http://search.maven.org/remotecontent?filepath=org/apache/tomcat/tomcat-dbcp/7.0.30/tomcat-dbcp-7.0.30.jar
#RUN service postgresql start
#RUN apt-get -y install facete2-tomcat7
#RUN service postgresql stop

# workaround SHMMAX problem of postgresql in some envs
# RUN sed -ie "s&^shared_buffers =.*&shared_buffers = 16MB&" "/etc/postgresql/9.3/main/postgresql.conf"

# configure supervisord
RUN mkdir -p /etc/supervisor/conf.d
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD etc.tomcat7.default /etc/default/tomcat7

RUN mkdir -p /opt/facete2/exports/
RUN chmod 777 /opt/facete2/exports

EXPOSE 8080

CMD ["/usr/bin/supervisord"]
